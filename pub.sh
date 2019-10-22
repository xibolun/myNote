echo "---------------- start --------------------"
git add .

git commit -am "commit message: $1"

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
