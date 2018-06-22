# typo3-templategenerator
Bash Script for generating a Typo3 Template Extension
general usage:

```
./newtemplate.sh -n MYVENDOR -a "My Name" -v ">=8.7;<9.0" -t "My Cool new Template" -d "my_template" -e "myemail@example.com"

Parameters:

-n Namespace of Extension, The Vendor
-a Author of the extension [default: console user]
-v Version of your preferred TYPO3 CMS [default: '>=7.6,<9.0']
-t Title of the Extension
-d Name of the directory (will be created, write with _, convert to - is inside) [default: 'template']
-e email of the author [default: empty]
-h this help
```
Creates a ready to use template Extension for typo3. Works currently with 7.6 and 8.7, 9.x is untested. Generates a default ts-Template, most needed directories, language-files
