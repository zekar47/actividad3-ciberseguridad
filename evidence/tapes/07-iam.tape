Output evidence/07-iam.png
Set FontSize 12
Set Width 1150
Set Height 1000
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 10ms
Set Shell "bash"

Hide
Type "export PS1='act3$ '; clear"
Enter
Show

Type "./scripts/validate-iam.sh 2>&1 | tail -55"
Enter
Sleep 7s
Screenshot evidence/07-iam.png
Sleep 1s
