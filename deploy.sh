echo "---------------- start --------------------"

echo "---------------- remove public-------------"
rm -rf public/*

echo "---------------- generate public-----------"
hugo --theme=hugo-pacman-theme --baseUrl="https://kedadiannao220.github.io/"

echo "---------------- cd   public---------------"
cd public

echo "---------------- commit public-------------"
git commit -am  "commit blog"

echo "---------------- push public---------------"
git push -f

echo "---------------- end  --------------------"




