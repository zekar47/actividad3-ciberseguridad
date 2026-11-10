Output evidence/02-terraform.png
Set FontSize 13
Set Width 1200
Set Height 820
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 10ms
Set Shell "bash"

Hide
Type "export PS1='act3$ '; export DOCKER_HOST=unix://$PWD/.tmp/docker3.sock; clear"
Enter
Show

Type "awslocal s3 rm s3://actividad3-seguro-2024 --recursive >/dev/null 2>&1; cd terraform && terraform destroy -auto-approve >/dev/null 2>&1 && terraform apply -auto-approve 2>&1 | tail -25"
Enter
Sleep 20s
Screenshot evidence/02-terraform.png
Sleep 1s
