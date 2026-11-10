Output evidence/03-s3.png
Set FontSize 12
Set Width 1100
Set Height 1000
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 10ms
Set Shell "bash"

Hide
Type "export PS1='act3$ '; clear"
Enter
Show

Type "./scripts/validate-s3.sh 2>&1 | tail -50"
Enter
Sleep 6s
Screenshot evidence/03-s3.png
Sleep 1s
