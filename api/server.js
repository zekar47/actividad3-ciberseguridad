'use strict';

const express = require('express');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const PORT = Number(process.env.PORT || 3000);
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_ISSUER = process.env.JWT_ISSUER || 'actividad3-api';
const JWT_AUDIENCE = process.env.JWT_AUDIENCE || 'actividad3-client';

if (!JWT_SECRET || JWT_SECRET.length < 32) {
  console.error('JWT_SECRET debe existir y tener al menos 32 caracteres.');
  process.exit(1);
}

// Usuarios de demostración. Las contraseñas se almacenan con hash bcrypt.
const users = [
  {
    username: 'admin',
    name: 'Administrador de la actividad',
    role: 'admin',
    passwordHash: bcrypt.hashSync('Admin#2024', 10),
  },
  {
    username: 'analista',
    name: 'Analista de seguridad',
    role: 'analyst',
    passwordHash: bcrypt.hashSync('Analista#2024', 10),
  },
];

const app = express();
app.disable('x-powered-by');
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      baseUri: ["'self'"],
      fontSrc: ["'self'"],
      formAction: ["'self'"],
      frameAncestors: ["'self'"],
      imgSrc: ["'self'", 'data:'],
      objectSrc: ["'none'"],
      scriptSrc: ["'self'"],
      scriptSrcAttr: ["'none'"],
      styleSrc: ["'self'"],
      upgradeInsecureRequests: [],
    },
  },
}));
app.use(express.json({ limit: '10kb' }));

const loginLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'demasiados_intentos', message: 'Espera un minuto antes de volver a intentar.' },
});

function publicUser(user) {
  return { username: user.username, name: user.name, role: user.role };
}

function authenticateToken(req, res, next) {
  const header = req.get('authorization') || '';
  const [scheme, token] = header.split(' ');

  if (scheme !== 'Bearer' || !token) {
    res.set('WWW-Authenticate', 'Bearer realm="actividad3"');
    return res.status(401).json({
      error: 'token_requerido',
      message: 'Debes enviar un token JWT en el encabezado Authorization: Bearer <token>.',
    });
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET, {
      algorithms: ['HS256'],
      issuer: JWT_ISSUER,
      audience: JWT_AUDIENCE,
    });
    req.user = payload;
    return next();
  } catch (error) {
    const expired = error.name === 'TokenExpiredError';
    res.set('WWW-Authenticate', 'Bearer error="invalid_token"');
    return res.status(401).json({
      error: expired ? 'token_expirado' : 'token_invalido',
      message: expired
        ? 'El token expiró; inicia sesión de nuevo.'
        : 'El token no es válido o no fue emitido por esta API.',
    });
  }
}

function requireRole(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user || !allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        error: 'permiso_denegado',
        message: 'El token es válido, pero el rol no tiene permiso para este recurso.',
      });
    }
    return next();
  };
}

app.get('/', (req, res) => {
  res.type('html').send(`<!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>Actividad 3 - API JWT</title></head>
<body>
  <h1>API de la Actividad 3</h1>
  <p>API de demostración con autenticación JWT.</p>
  <ul>
    <li><a href="/health">/health</a> - estado del servicio</li>
    <li><a href="/api/profile">/api/profile</a> - requiere token JWT</li>
    <li><a href="/api/admin">/api/admin</a> - requiere rol admin</li>
    <li><a href="/api/reports">/api/reports</a> - requiere rol admin o analyst</li>
  </ul>
  <p>El inicio de sesión se realiza con <code>POST /auth/login</code>.</p>
</body>
</html>`);
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'actividad3-api', timestamp: new Date().toISOString() });
});

app.post('/auth/login', loginLimiter, (req, res) => {
  const { username, password } = req.body || {};

  if (typeof username !== 'string' || typeof password !== 'string') {
    return res.status(400).json({
      error: 'solicitud_invalida',
      message: 'Debes enviar username y password.',
    });
  }

  const user = users.find((candidate) => candidate.username === username);
  const validPassword = user ? bcrypt.compareSync(password, user.passwordHash) : false;

  if (!user || !validPassword) {
    return res.status(401).json({
      error: 'credenciales_invalidas',
      message: 'Usuario o contraseña incorrectos.',
    });
  }

  const token = jwt.sign(
    { sub: user.username, name: user.name, role: user.role },
    JWT_SECRET,
    {
      algorithm: 'HS256',
      expiresIn: '15m',
      issuer: JWT_ISSUER,
      audience: JWT_AUDIENCE,
    },
  );

  return res.json({
    token_type: 'Bearer',
    expires_in: 900,
    access_token: token,
    user: publicUser(user),
  });
});

// Endpoint sensible 1: cualquier usuario autenticado puede consultar su perfil.
app.get('/api/profile', authenticateToken, (req, res) => {
  const user = users.find((candidate) => candidate.username === req.user.sub);
  if (!user) {
    return res.status(404).json({ error: 'usuario_no_encontrado' });
  }
  return res.json({
    message: 'Perfil consultado con un token JWT válido.',
    user: publicUser(user),
    token_claims: {
      sub: req.user.sub,
      role: req.user.role,
      issuer: req.user.iss,
      audience: req.user.aud,
      expires_at: new Date(req.user.exp * 1000).toISOString(),
    },
  });
});

// Endpoint sensible 2: sólo el rol administrador.
app.get('/api/admin', authenticateToken, requireRole('admin'), (req, res) => {
  return res.json({
    message: 'Acceso concedido al panel de administración.',
    requested_by: req.user.sub,
    role: req.user.role,
    admin_data: {
      bucket: 'actividad3-seguro-2024',
      encryption: 'AES256',
      public_access_blocked: true,
    },
  });
});

// Endpoint sensible 3: administrador o analista.
app.get('/api/reports', authenticateToken, requireRole('admin', 'analyst'), (req, res) => {
  return res.json({
    message: 'Reporte de seguridad disponible.',
    requested_by: req.user.sub,
    role: req.user.role,
    reports: [
      { id: 1, name: 'trivy-node14', severity: 'critical' },
      { id: 2, name: 'trivy-node18', severity: 'none-critical' },
      { id: 3, name: 'zap-baseline', severity: 'informational' },
    ],
  });
});

app.use((req, res) => {
  res.status(404).json({ error: 'ruta_no_encontrada' });
});

app.use((error, req, res, next) => {
  if (error instanceof SyntaxError && error.status === 400 && 'body' in error) {
    return res.status(400).json({ error: 'json_invalido' });
  }
  console.error(error);
  return res.status(500).json({ error: 'error_interno' });
});

app.listen(PORT, '127.0.0.1', () => {
  console.log(`API escuchando en http://127.0.0.1:${PORT}`);
  console.log(`Emisor JWT: ${JWT_ISSUER} | Audiencia: ${JWT_AUDIENCE}`);
});
