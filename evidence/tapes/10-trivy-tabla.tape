Output evidence/10-trivy-tabla.png
Set FontSize 11
Set Width 1300
Set Height 1000
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 10ms
Set Shell "bash"

Hide
Type "export PS1='act3$ '; export DOCKER_HOST=unix://$PWD/.tmp/docker3.sock; clear"
Enter
Show

Type "trivy image --scanners vuln --severity CRITICAL --no-progress actividad3-api:node14 2>/dev/null | head -38"
Enter
Sleep 24s
Screenshot evidence/10-trivy-tabla.png
Sleep 1s
