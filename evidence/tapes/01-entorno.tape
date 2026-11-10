Output evidence/01-entorno.png
Set FontSize 14
Set Width 1200
Set Height 720
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 15ms
Set Shell "bash"

Hide
Type "export PS1='act3$ '; export DOCKER_HOST=unix://$PWD/.tmp/docker3.sock; clear"
Enter
Show

Type "aws --version; terraform version | head -1; trivy --version | head -1; node --version; awslocal --version"
Enter
Sleep 3s

Type "curl -s http://localhost:4566/_localstack/health | jq '{version, services: {s3: .services.s3, iam: .services.iam, sts: .services.sts}}'"
Enter
Sleep 4s
Screenshot evidence/01-entorno.png
Sleep 1s
