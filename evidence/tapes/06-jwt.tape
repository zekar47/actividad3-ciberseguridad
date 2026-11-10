Output evidence/06-jwt.png
Set FontSize 13
Set Width 1150
Set Height 720
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 10ms
Set Shell "bash"

Hide
Type "export PS1='act3$ '; clear"
Enter
Show

Type "./scripts/validate-jwt.sh 2>&1 | grep -E '^(==|HTTP)'"
Enter
Sleep 9s
Screenshot evidence/06-jwt.png
Sleep 1s
