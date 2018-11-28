#!/bin/bash
function help {
  echo "Parameters:"
  echo ""
  echo "-n Namespace of Extension, The Vendor"
  echo "-a Author of the extension [default: console user]"
  echo "-v Version of your preferred TYPO3 CMS [default: '~9.5.0']"
  echo "-t Title of the Extension"
  echo "-d Name of the directory (will be created, write with _, convert to - is inside) [default: 'template']"
  echo "-e email of the author [default: empty]"
  echo "-h this help"
  exit
}

while getopts a:e:v:n:d:t:h option
do
	case "${option}"
	in
	a) author=${OPTARG};;
	e) email=${OPTARG};;
	v) t3version=${OPTARG};;
	n) namespace=${OPTARG};;
	d) directory=${OPTARG};;
	t) title=${OPTARG};;
	h) help;;
	esac
done

if [ -z "$namespace" ];
then
	echo "No namespace defined"
	help
fi

if [ -z "$title" ];
then
	echo "title not defined"
	help
fi

if [ -z "$author" ];
then
	author=${USER};
fi

if [ -z "$email" ];
then
	email=""
fi

if [ -z "$t3version" ];
then
	t3version="~9.5.0"
fi

if [ -z "$directory" ];
then
	directory="template"
fi

mkdir $directory

template=$directory

cd $directory
mkdir -p Classes/Controller
mkdir -p Configuration/Flexforms
mkdir -p Configuration/PageTSconfig
mkdir -p Configuration/TypoScript
mkdir -p Configuration/TCA/Overrides
mkdir -p Resources/Private
mkdir -p Resources/Private/Language
mkdir -p Resources/Private/Layouts
mkdir -p Resources/Private/Partials
mkdir -p Resources/Private/Templates

mkdir -p Resources/Public
mkdir -p Resources/Public/Icons
mkdir -p Resources/Public/Css
mkdir -p Resources/Public/Js

touch Configuration/TypoScript/setup.typoscript
touch Configuration/TypoScript/constants.typoscript
touch Configuration/PageTSconfig/page.tsconfig

touch ext_tables.php
touch ext_localconf.php
touch ext_emconf.php
touch ext_tables.sql
touch Configuration/TCA/Overrides/sys_template.php
touch Resources/Private/Language/locallang.xlf

echo "<?php" > Configuration/TCA/Overrides/tt_content.php
echo "return [];" >> Configuration/TCA/Overrides/tt_content.php

touch Resources/Public/Icons/.gitkeep
touch Resources/Public/Css/styles.css
touch Resources/Public/Js/main.js
touch Resources/Private/Layouts/Default.html
touch Resources/Private/Partials/.gitkeep
touch Resources/Private/Templates/Default.html
touch Configuration/Flexforms/.gitkeep
touch Classes/Controller/.gitkeep

arr=(${template//_/ })
printf -v ccase %s "${arr[@]^}"

# writing composer.json
echo "{" > composer.json
echo '    "name": "MYVENDOR/mynewtemplate",' >> composer.json
echo '    "description": "MYTITLE",' >> composer.json
echo '    "version": "1.0.0",' >> composer.json
echo '    "type": "typo3-cms-extension",' >> composer.json
echo '    "authors": [' >> composer.json
echo '        {' >> composer.json
echo '            "name": "creator",' >> composer.json
echo '            "role": "Developer",' >> composer.json
echo '            "email": "emailtext"' >> composer.json
echo '        }' >> composer.json
echo '    ],' >> composer.json
echo '    "require": {' >> composer.json
echo '        "typo3/cms-core": "myversion"' >> composer.json
echo '    },' >> composer.json
echo '    "autoload": {' >> composer.json
echo '        "psr-4": {' >> composer.json
echo '            "MYVENDOR\\MyNamespace\\": "Classes/"' >> composer.json
echo '        }' >> composer.json
echo '    }' >> composer.json
echo '}' >> composer.json

# rename the markers in composer.json
sed -i "s/mynewtemplate/${template/_/-}/g" composer.json
sed -i "s/MyNamespace/$ccase/g" composer.json
sed -i "s/creator/$author/g" composer.json
sed -i "s/emailtext/$email/g" composer.json
sed -i "s/myversion/$t3version/g" composer.json
sed -i "s/MYVENDOR/$namespace/g" composer.json
sed -i "s/MYTITLE/$title/g" composer.json

#write basic sys_template.php
echo -e "<?php\n\nif (!defined('TYPO3_MODE')) die();\n\n\\TYPO3\\CMS\\Core\\Utility\\\ExtensionManagementUtility::addStaticFile('$directory','Configuration/TypoScript/','B-Factor Template');" > Configuration/TCA/Overrides/sys_template.php

# write basic ext_localconf.php
echo -e "<?php\n\nif (!defined('TYPO3_MODE')) die();" > ext_localconf.php

# write pageTS integration
echo -e "<?php\n\nif (!defined('TYPO3_MODE')) die();\n" > Configuration/TCA/Overrides/pages.php
echo -e "call_user_func(function () {\n    \\TYPO3\\CMS\\Core\\Utility\\\ExtensionManagementUtility::registerPageTSConfigFile(" >> Configuration/TCA/Overrides/pages.php
echo -e "        '$template',\n        'Configuration/PageTSconfig/page.tsconfig',\n        'Seitendefinitionen B-Factor Template'" >> Configuration/TCA/Overrides/pages.php
echo -e "    );\n});" >> Configuration/TCA/Overrides/pages.php

# write standard page config
echo -e "page = PAGE\npage.typeNum = 0\npage.10 = FLUIDTEMPLATE\npage.10 {\n    format = html" > Configuration/TypoScript/setup.typoscript
#echo -e "" >> Configuration/TypoScript/setup.typoscript
echo -e "    file = EXT:$template/Resources/Private/Templates/Default.html" >> Configuration/TypoScript/setup.typoscript
echo -e "    layoutRootPaths {\n        10 = EXT:$template/Resources/Private/Layouts/\n    }" >> Configuration/TypoScript/setup.typoscript
echo -e "    partialRootPaths {\n        10 = EXT:$template/Resources/Private/Partials/\n    }" >> Configuration/TypoScript/setup.typoscript
echo -e "    templateRootPaths {\n        10 = EXT:$template/Resources/Private/Templates/\n    }\n}" >> Configuration/TypoScript/setup.typoscript
echo -e "page.includeJSFooter {" >> Configuration/TypoScript/setup.typoscript
#echo -e "    jquery = //ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js\n    jquery.external = 1" >> Configuration/TypoScript/setup.typoscript
echo -e "    main = EXT:$template/Resources/Public/Js/main.js" >> Configuration/TypoScript/setup.typoscript
echo -e "}" >> Configuration/TypoScript/setup.typoscript
echo -e "page.includeCSS {" >> Configuration/TypoScript/setup.typoscript
echo -e "    main = EXT:$template/Resources/Public/Css/styles.css" >> Configuration/TypoScript/setup.typoscript
echo -e "}" >> Configuration/TypoScript/setup.typoscript
echo -e "config {" >> Configuration/TypoScript/setup.typoscript
echo -e "    language = de" >> Configuration/TypoScript/setup.typoscript
echo -e "    spamProtectEmailAddresses = -2" >> Configuration/TypoScript/setup.typoscript
echo -e '    spamProtectEmailAddresses_atSubst = <span style="display:none;">dontospamme</span>@<wbr><span style="display:none;">gowaway.</span>' >> Configuration/TypoScript/setup.typoscript
echo -e "}" >> Configuration/TypoScript/setup.typoscript

# write the default template
echo -e '<html xmlns:f="http://typo3.org/ns/TYPO3/Fluid/ViewHelpers" xmlns="http://www.w3.org/1999/xhtml" lang="en" f:schemaLocation="https://fluidtypo3.org/schemas/fluid-master.xsd" data-namespace-typo3-fluid="true">' > Resources/Private/Templates/Default.html
echo -e '<f:layout name="Default" />' >> Resources/Private/Templates/Default.html
echo -e '<f:section name="content">\n    <f:cObject typoscriptObjectPath="styles.content.get" />\n</f:section>\n</html>' >> Resources/Private/Templates/Default.html

# write the layout
echo -e '<html xmlns:f="http://typo3.org/ns/TYPO3/Fluid/ViewHelpers" xmlns="http://www.w3.org/1999/xhtml" lang="en" f:schemaLocation="https://fluidtypo3.org/schemas/fluid-master.xsd" data-namespace-typo3-fluid="true">' > Resources/Private/Layouts/Default.html
echo -e '<div id="main">\n    <f:render section="content" />\n</div>' >> Resources/Private/Layouts/Default.html
echo -e '</html>' >> Resources/Private/Layouts/Default.html

# write Declaration file
echo -e "<?php\n\n\$EM_CONF[\$_EXTKEY] = [" > ext_emconf.php
echo -e "    'title' => 'MYTITLE'," >> ext_emconf.php
echo -e "    'description' => '$template'," >> ext_emconf.php
echo -e "    'category' => 'templates'," >> ext_emconf.php
echo -e "    'state' => 'beta'," >> ext_emconf.php
echo -e "    'author' => '$author'," >> ext_emconf.php
echo -e "    'author_email' => '$email'," >> ext_emconf.php
echo -e "    'version' => '1.0.0'," >> ext_emconf.php
echo -e "];" >> ext_emconf.php

sed -i "s/MYTITLE/$title/g" ext_emconf.php

#write default language file
echo -e '<?xml version="1.0" encoding="utf-8" standalone="yes" ?>' > Resources/Private/Language/locallang.xlf
#echo -e '' >> Resources/Private/Language/locallang.xlf
echo -e '<xliff version="1.0">' >> Resources/Private/Language/locallang.xlf
echo -e '    <file source-language="en" datatype="plaintext" original="messages" date="DATESTAMP">' >> Resources/Private/Language/locallang.xlf
echo -e '        <header>\n            <generator>OwnScript</generator>\n        </header>\n        <body>\n        </body>\n    </file>\n</xliff>' >> Resources/Private/Language/locallang.xlf

actdate=$(date +%Y-%m-%dT%H:%M:%SZ)

sed -i "s/DATESTAMP/$actdate/g" Resources/Private/Language/locallang.xlf
