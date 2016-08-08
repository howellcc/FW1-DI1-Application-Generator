component extends="frameworks.org.corfield.framework" {

	this.name = 'fw1-di1-application-generator-2';
	this.sessionmanagement = true;
    this.clientmanagement = true;
    this.scriptprotect = true;

	// FW/1 - configuration:
	variables.framework = {
		action = 'action',
		defaultSection = 'main',
		defaultItem = 'home',
		home = 'main.home',
		error = 'main.error',
		reload = 'reload',
		password = 'true',
		reloadApplicationOnEveryRequest = true,
		debugmode = true
	};

	function setupApplication()
	{
        var beanFactory = new frameworks.org.corfield.ioc( "model" );
        setBeanFactory( beanFactory );
	}

	function onError(exception, eventName) {
		writeDump(eventName);
		writeDump(exception);
	}

}