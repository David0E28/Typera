::自动提交到github
set date = get-date
git add .  
git commit -m  "%date%"
git push