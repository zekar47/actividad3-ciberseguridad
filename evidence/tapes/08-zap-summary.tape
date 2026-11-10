Output evidence/08-zap-summary.png
Set FontSize 13
Set Width 1400
Set Height 620
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 10ms
Set Shell "bash"

Hide
Type "export PS1='act3$ '; clear"
Enter
Show

Type "./scripts/zap-summary.sh evidence/zap-report-inicial.html"
Enter
Sleep 2s
Type "./scripts/zap-summary.sh evidence/zap-report.html"
Enter
Sleep 3s
Screenshot evidence/08-zap-summary.png
Sleep 1s
