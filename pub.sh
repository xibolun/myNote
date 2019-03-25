##### pub脚本说明
##### master为文章的主分支
##### public目录下面是另一个repository，gitpage必须以Master分支来作为发布分支，所以必须另起一个repository
##### 将public目录删除，然后重新生成，提交至public的master分支，即可发布
##### 发布会有延时
echo "---------------- start --------------------"
git add .

git commit -am "commit blog master"

git push origin master

echo "---------------- remove public-------------"
rm -rf public/* -y

echo "---------------- generate public-----------"
hugo 

echo "---------------- cd   public---------------"
cd public

echo "---------------- commit public-------------"
git add .
git commit -am  "commit blog"

echo "---------------- push public---------------"
git push -f

echo "---------------- end  --------------------"
