#!/usr/bin/env sh

# abort on errors
set -e

# Access docs folder
cd docs

# build
npm run docs:build

# navigate into the build output directory
cd docs/.vuepress/dist

# if you are deploying to a custom domain
# echo 'www.example.com' > CNAME

git init
git add -A
git commit -m 'deploy'

git push -f git@github.com:ing-bank/zkproofs.git master:gh-pages

cd -
