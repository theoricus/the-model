POLVO=node_modules/polvo/bin/polvo

SELENIUM=test/services/selenium-server-standalone-2.35.0.jar
SAUCE_CONNECT=test/services/Sauce-Connect.jar
CHROME_DRIVER=test/services/chromedriver

CS=node_modules/coffee-script/bin/coffee
MOCHA=node_modules/mocha/bin/mocha
COVERALLS=node_modules/coveralls/bin/coveralls.js

MVERSION=node_modules/mversion/bin/version
VERSION=`$(MVERSION) | sed -E 's/\* package.json: //g'`


setup: install_test_suite
	npm install
	bower install


watch:
	@$(CS) -bwo lib src

build:
	@$(CS) -bco lib src

build.test: build
	@cp lib/index.js test/fixturess/the-model.js



bump.minor:
	@$(MVERSION) minor

bump.major:
	@$(MVERSION) major

bump.patch:
	@$(MVERSION) patch



publish:
	git tag $(VERSION)
	git push origin $(VERSION)
	git push origin master
	npm publish

re-publish:
	git tag -d $(VERSION)
	git tag $(VERSION)
	git push origin :$(VERSION)
	git push origin $(VERSION)
	git push origin master -f
	npm publish -f



# TEST
# ------------------------------------------------------------------------------

# setup
install_test_suite:
	@mkdir -p test/services

	@echo '-----'
	@echo 'Downloading Selenium..'
	@curl -o test/services/selenium-server-standalone-2.35.0.jar \
		https://selenium.googlecode.com/files/selenium-server-standalone-2.35.0.jar
	@echo 'Done.'

	@echo '-----'
	@echo 'Downloading Chrome Driver..'
	@curl -o test/services/chromedriver.zip \
		https://chromedriver.googlecode.com/files/chromedriver_mac32_2.3.zip
	@echo 'Done.'

	@echo '-----'
	@echo 'Unzipping chromedriver..'
	@cd test/services/; unzip chromedriver.zip; \
		rm chromedriver.zip; cd -
	@echo 'Done.'

	@echo '-----'
	@echo 'Downloading Sauce Connect..'
	@curl -o test/services/sauceconnect.zip \
		http://saucelabs.com/downloads/Sauce-Connect-latest.zip

	@echo '-----'
	@echo 'Unzipping Sauce Connect..'
	@cd test/services/; unzip sauceconnect.zip; \
		rm NOTICE.txt license.html sauceconnect.zip; cd -
	@echo '-----'
	@echo 'Done.'
	@echo



# services
test.selenium.run:
	@java -jar $(SELENIUM) -Dwebdriver.chrome.driver=$(CHROME_DRIVER)

test.sauce.connect.run:
	@java -jar $(SAUCE_CONNECT) $(SAUCE_USERNAME) $(SAUCE_ACCESS_KEY)

# building
test.build.prod:
	@echo 'Building app before testing..'
	@$(POLVO) -rb test/fixtures/app > /dev/null

test.build.split:
	@echo 'Compiling app before testing..'
	@$(POLVO) -cxb test/fixtures/app > /dev/null



# coverage
test.cover.normalize:
	@sed -i.bak \
		"s/^.*public\/__split__\/lib/SF:lib/g" \
		test/coverage/lcov.info

test.cover.publish:
	@cd test/fixtures/app/public/__split__/ && \
		cat ../../../../coverage/lcov.info | \
		../../../../../$(COVERALLS)

	@cd ../../../../..

test.api.run:
	@cd test/fixtures/api; ../../../$(CS) index.coffee --autoinit

test.app.run:
	@cd test/fixtures/app; ../../../$(POLVO) -ws

# local
test: test.build.prod
	@$(MOCHA) --compilers coffee:coffee-script \
		--ui bdd \
		--reporter spec \
		--timeout 600000 \
		test/runner.coffee --env='local'

test.cover: test.build.split
	@$(MOCHA) --compilers coffee:coffee-script \
	--ui bdd \
	--reporter spec \
	--timeout 600000 \
	test/runner.coffee --env='local' --coverage



# coveralls
test.coveralls: test.cover test.cover.normalize test.cover.publish

test.cover.preview: test.cover
	@cd test/coverage/lcov-report; python -m SimpleHTTPServer 8080; cd -



# sauce labs
test.sauce: test.build.prod
	@$(MOCHA) --compilers coffee:coffee-script \
	--ui bdd \
	--reporter spec \
	--timeout 600000 \
	test/runner.coffee --env='sauce labs'

test.sauce.cover: test.build.split
	@$(MOCHA) --compilers coffee:coffee-script \
	--ui bdd \
	--reporter spec \
	--timeout 600000 \
	test/runner.coffee --env='sauce labs' --coverage

test.sauce.coveralls: test.sauce.cover test.cover.normalize test.cover.publish
