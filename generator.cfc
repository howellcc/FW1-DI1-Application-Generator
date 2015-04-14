component {

	// constructor
	public any function init(required string dsn, required string siteTitle, string tables, string table) {

		// set arguments into the variables scope so they can be used throughout the cfc
		variables.dsn = arguments.dsn;
		variables.siteTitle = arguments.siteTitle;
		if(structKeyExists(arguments, 'tables')) {
			variables.tables = arguments.tables;
		}
		if(structKeyExists(arguments, 'table')) {
			variables.table = arguments.table;
			variables.tableColumns = getColumns(variables.table);

			for(i=1;i<=variables.tableColumns.recordCount;i++) {
				if(variables.tableColumns.Is_PrimaryKey[i] EQ true) {
					var variables.pkField = variables.tableColumns.column_name[i];
				}
			}
		}

		variables.nounForms = CreateObject("component", "nounForms").init();

	  	variables.apos = "'";
	  	variables.quot = '"';

		return this;
	}

	// Get Database Info (Table Names)
	remote query function getTables() {
		t1 = new dbinfo(datasource=variables.dsn).tables();
		q = new query();
		q.setDBType('query');
	    q.setAttributes(t=t1);
		q.setSQL("select * from d where table_type like 'TABLE'");
		return q.execute().getResult();
	}

	// Get Table Info (Column Names)
	public query function getColumns(required string table) {
		return new dbinfo(datasource=variables.dsn).columns(table=arguments.table);
	}

	// Capitalize first letter of a string
	public string function capitalizeString( required string s ) {
		return ReReplace(s,"\b(\w)","\u\1");
	}

	// Break string into words by capitol letter
	public string function decamelizeString( required string s ) {
		return ReReplace(capitalizeString(s), "([a-z])([A-Z])", "\1 \2", "ALL");
	}

	// Application CFC Generator
	public string function generateApplicationCFC() {
		var retVar = 'component extends="frameworks.org.corfield.framework" {' & chr(13) & chr(10) & chr(13) & chr(10);
			retVar &= chr(9) & 'this.datasource = "#variables.dsn#";' & chr(13) & chr(10);
			retVar &= chr(9) & 'this.sessionmanagement = true;' & chr(13) & chr(10);
			retVar &= chr(9) & 'this.clientManagement  = true;' & chr(13) & chr(10);
			retVar &= chr(9) & 'this.scriptprotect = true;' & chr(13) & chr(10);
			retVar &= chr(9) & 'this.sitetitle = "#variables.sitetitle#";' & chr(13) & chr(10) & chr(13) & chr(10);

			retVar &=  chr(9) & 'variables.framework = {' & chr(13) & chr(10);
				retVar &=  chr(9) & chr(9) & 'action = "action",' & chr(13) & chr(10);
				retVar &=  chr(9) & chr(9) & 'defaultSection = "main",' & chr(13) & chr(10);
				retVar &=  chr(9) & chr(9) & 'defaultItem = "default",' & chr(13) & chr(10);
				retVar &=  chr(9) & chr(9) & 'default = "main.default",' & chr(13) & chr(10);
				retVar &=  chr(9) & chr(9) & 'error = "main.error",' & chr(13) & chr(10);
				retVar &=  chr(9) & chr(9) & 'reload = "reload",' & chr(13) & chr(10);
				retVar &=  chr(9) & chr(9) & 'password = "true",' & chr(13) & chr(10);
				retVar &=  chr(9) & chr(9) & '// Reload application on every request set to true for development purposes' & chr(13) & chr(10);
				retVar &=  chr(9) & chr(9) & '// Strongly recommended to change to false before pushing to production' & chr(13) & chr(10);
				retVar &=  chr(9) & chr(9) & 'reloadApplicationOnEveryRequest = true' & chr(13) & chr(10);
			retVar &=  chr(9) & '};' & chr(13) & chr(10) & chr(13) & chr(10);

			retVar &=  chr(9) & 'function setupApplication() {' & chr(13) & chr(10);
        		retVar &=  chr(9) & chr(9) & 'var beanFactory = new frameworks.org.corfield.ioc( "model" );' & chr(13) & chr(10);
        		retVar &=  chr(9) & chr(9) & 'setBeanFactory( beanFactory );' & chr(13) & chr(10) & chr(13) & chr(10);

				retVar &=  chr(9) & chr(9) & 'Application.Datasource = this.datasource;' & chr(13) & chr(10);
				retVar &=  chr(9) & chr(9) & 'Application.SiteTitle = this.sitetitle;' & chr(13) & chr(10);
			retVar &=  chr(9) & '}' & chr(13) & chr(10);
		retVar &= '}';

		return retVar;
	}

	// Default Layout Generator
	public string function generateDefaultLayout() {
		var retVar = '<!DOCTYPE html>' & chr(13) & chr(10);
			retVar &=  '<html lang="en">' & chr(13) & chr(10);
			retVar &=  '<head>' & chr(13) & chr(10);
			retVar &=  chr(9) & '<meta charset="utf-8">' & chr(13) & chr(10);
			retVar &=  chr(9) & '<meta name="viewport" content="width=device-width, initial-scale=1.0">' & chr(13) & chr(10);
			retVar &=  chr(9) & '<title><cfoutput>Title</cfoutput></title>' & chr(13) & chr(10) & chr(13) & chr(10);

			retVar &=  chr(9) & '<script src="//code.jquery.com/jquery-1.10.2.js"></script>' & chr(13) & chr(10);
			retVar &=  chr(9) & '<script src="//code.jquery.com/ui/1.11.0/jquery-ui.js"></script>' & chr(13) & chr(10);
			retVar &=  chr(9) & '<script src="//ajax.aspnetcdn.com/ajax/jquery.validate/1.13.0/jquery.validate.js"></script>' & chr(13) & chr(10);
			retVar &=  chr(9) & '<script src="//ajax.aspnetcdn.com/ajax/jquery.validate/1.13.0/additional-methods.min.js"></script>' & chr(13) & chr(10);
			retVar &=  chr(9) & '<script src="//cdn.datatables.net/1.10.1/js/jquery.dataTables.min.js"></script>' & chr(13) & chr(10) & chr(13) & chr(10);

			retVar &=  chr(9) & '<link href="//ajax.aspnetcdn.com/ajax/jquery.ui/1.10.1/themes/redmond/jquery-ui.min.css" rel="stylesheet" />' & chr(13) & chr(10);
			retVar &=  chr(9) & '<link href="css/demo_table_jui.css" rel="stylesheet" />' & chr(13) & chr(10);
			retVar &=  chr(9) & '<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet" />' & chr(13) & chr(10) & chr(13) & chr(10);

			retVar &=  chr(9) & '<link href="http://yui.yahooapis.com/pure/0.5.0/pure-min.css" rel="stylesheet" />' & chr(13) & chr(10) & chr(13) & chr(10);

 			retVar &=  chr(9) & '<!--[if lte IE 8]>' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & '<link rel="stylesheet" href="css/layouts/side-menu-old-ie.css">' & chr(13) & chr(10);
			retVar &=  chr(9) & '<![endif]-->' & chr(13) & chr(10);
			retVar &=  chr(9) & '<!--[if gt IE 8]><!-->' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & '<link rel="stylesheet" href="css/layouts/side-menu.css">' & chr(13) & chr(10);
 			retVar &=  chr(9) & '<!--<![endif]-->' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & '<link rel="stylesheet" href="css/styles.css">' & chr(13) & chr(10);
			retVar &= '</head>' & chr(13) & chr(10) & chr(13) & chr(10);

			retVar &= '<body>' & chr(13) & chr(10);
			retVar &=  chr(9) & '<div id="layout">' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & '<!-- Menu toggle -->' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & '<a href="##menu" id="menuLink" class="menu-link">' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & chr(9) & '<!-- Hamburger icon -->' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & chr(9) & '<span></span>' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & '</a>' & chr(13) & chr(10) & chr(13) & chr(10);

			retVar &=  chr(9) & chr(9) & '<div id="menu">' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & chr(9) & '<div class="pure-menu pure-menu-open">' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & chr(9) & chr(9) & '<cfoutput><a class="pure-menu-heading" href="##buildURL(#variables.apos#main.default#variables.apos#)##">Title</a></cfoutput>' & chr(13) & chr(10) & chr(13) & chr(10);

			retVar &=  chr(9) & chr(9) & chr(9) & chr(9) & '<ul>' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<cfoutput>' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<li><a href="##buildURL(#variables.apos#main.default#variables.apos#)##">Home</a></li>' & chr(13) & chr(10);

			for(i=1;i<=listlen(variables.tables);i++) {
				retVar &=  chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<li><a href="##buildURL(#variables.apos##listgetat(variables.tables,i)#.default#variables.apos#)##">#capitalizeString(listgetat(variables.tables,i))#</a></li>' & chr(13) & chr(10);
			}

			retVar &=  chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '</cfoutput>' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & chr(9) & chr(9) & '</ul>' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & '</div>' & chr(13) & chr(10) & chr(13) & chr(10);

			retVar &=  chr(9) & chr(9) & '<div id="main">' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & '<cfoutput>##body##</cfoutput>' & chr(13) & chr(10);
			retVar &=  chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
			retVar &=  chr(9) & '</div>' & chr(13) & chr(10);
			retVar &= '</body>' & chr(13) & chr(10);
			retVar &= '</html>';

		return retVar;
	}

	// Table Config Generator
	public string function generateBean() {
		var qColumns = getColumns(variables.table);
		var bean = "component accessors=true {" & chr(13) & chr(10);
		for(i=1;i<=qColumns.recordCount;i++) {
			var line = chr(9) & "property ";
			switch(qColumns.type_name[i]) {
				case "decimal": case "float": case "int": case "money": case "numeric": case "real": case "smallint": case "smallmoney": case "tinyint":
					line &= "numeric ";
					break;
				case "date": case "smalldatetime": case "time": case "datetime":
					line &= "date ";
					break;
				case "bit":
					line &= "boolean ";
					break;
				case "uniqueidentifier":
					line &= "guid ";
					break;
				default:
					line &= "string ";
					break;
			}
			line &= qColumns.column_name[i] & ";" & chr(13) & chr(10) ;
			bean &= line;
		}
		bean &= "}";

		return bean;
	}

	// Controller Generator
	public string function generateController() {
		var service = variables.table & "Service";
		var serviceCall = "variables." & service;

		var controller = "component persistent='false' accessors='true' output='false' extends='controller' {" & chr(13) & chr(10) & chr(13) & chr(10);
		controller &= chr(9) & "property " & service & ";" & chr(13) & chr(10);
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
				keyTable = nounForms.pluralize(mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3));
				controller &= chr(9) & "property " & keyTable & "Service;" & chr(13) & chr(10);
			}
		}
		// controller &= chr(13) & chr(10) & chr(9) & "function init( fw ) {" & chr(13) & chr(10);
		// controller &= chr(9) & chr(9) & "variables.fw = fw;" & chr(13) & chr(10);
		// controller &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		controller &= chr(13) & chr(10) & chr(9) & "public any function before(required struct rc) {" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & "#serviceCall#.setDatasource();" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & "#serviceCall#.setSchema();" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & "super.before(rc);" & chr(13) & chr(10);
		controller &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		controller &= chr(13) & chr(10);
		controller &= chr(9) & "// *********************************  PAGES  *******************************************";
		controller &= chr(13) & chr(10);

		controller &= chr(9) & "public any function default(required struct rc ) {" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & "rc." & variables.table & " = " & serviceCall & ".getAll();" & chr(13) & chr(10);
		controller &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		controller &= chr(9) & "public void function create(required struct rc ) {" & chr(13) & chr(10);
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
				keyTable = nounForms.pluralize(mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3));
				controller &= chr(9) & chr(9) & "rc." & keyTable & " = variables." & keyTable & "Service.getAll();" & chr(13) & chr(10);
			}
		}
		controller &= chr(9) & chr(9) & "if(structKeyExists(rc, 'btnSubmit')) {" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & chr(9) & "rc.msg = " & serviceCall & ".create( rc );" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & "}" & chr(13) & chr(10);
		controller &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		controller &= chr(9) & "public any function view(required struct rc ) {" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & "rc." & variables.table & "Bean = " & serviceCall & ".getBeanById(rc." & variables.pkField & ");" & chr(13) & chr(10);
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
				keyTable = mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3);
				controller &= chr(9) & chr(9) & "rc." & keyTable & " = variables." & keyTable & "Service.getAll();" & chr(13) & chr(10);
				controller &= chr(9) & chr(9) & "rc.#nounForms.singularize(variables.table)##capitalizeString(nounForms.singularize(keyTable))# = variables.#keyTable#Service.getBeanById(rc.#keyTable#Bean.get#capitalizeString(keyTable)#_fk());" & chr(13) & chr(10);
			}
		}
		controller &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		controller &= chr(9) & "public any function viewEdit(required struct rc ) {" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & "rc." & variables.table & "Bean = " & serviceCall & ".getBeanById(rc." & variables.pkField & ");" & chr(13) & chr(10);
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
				keyTable = mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3);
				controller &= chr(9) & chr(9) & "rc." & keyTable & " = variables." & keyTable & "Service.getAll();" & chr(13) & chr(10);
				controller &= chr(9) & chr(9) & "rc.#nounForms.singularize(variables.table)##capitalizeString(nounForms.singularize(keyTable))# = variables.#keyTable#Service.getBeanById(rc.#keyTable#Bean.get#capitalizeString(keyTable)#_fk());" & chr(13) & chr(10);
			}
		}
		controller &= chr(9) & chr(9) & "if(structKeyExists(rc, 'btnSubmit')) {" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & chr(9) & "rc.msg = " & serviceCall & ".update( rc );" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & chr(9) & "rc." & variables.table & "Bean = " & serviceCall & ".getBeanById(rc." & variables.pkField & ");" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & "}" & chr(13) & chr(10);
		controller &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		controller &= chr(9) & "public any function update(required struct rc ) {" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & "rc." & variables.table & "Bean = " & serviceCall & ".getBeanById(rc." & variables.pkField & ");" & chr(13) & chr(10);
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
				keyTable = mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3);
				controller &= chr(9) & chr(9) & "rc." & keyTable & " = variables." & keyTable & "Service.getAll();" & chr(13) & chr(10);
			}
		}
		controller &= chr(9) & chr(9) & "if(structKeyExists(rc, 'btnSubmit')) {" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & chr(9) & "rc.msg = " & serviceCall & ".update( rc );" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & chr(9) & "rc." & variables.table & "Bean = " & serviceCall & ".getBeanById(rc." & variables.pkField & ");" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & "}" & chr(13) & chr(10);
		controller &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		controller &= chr(9) & "public any function delete(required struct rc ) {" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & "var bean = " & serviceCall & ".getBeanById(rc." & variables.pkField & ");" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & "rc.msg = " & serviceCall & ".delete( bean );" & chr(13) & chr(10);
		controller &= chr(9) & chr(9) & "variables.fw.redirect( '" & variables.table & ".default' );" & chr(13) & chr(10);
		controller &= chr(9) & "}" & chr(13) & chr(10);

		controller &= chr(13) & chr(10);
		controller &= chr(9) & "// *********************************  PRIVATE METHODS  *******************************************";
		controller &= chr(13) & chr(10);

		controller &= "}";

		return controller;
	}

	// Service Generator
	public string function generateService() {
		dao = variables.table & "DAO";

		var service = "component accessors=true {" & chr(13) & chr(10) & chr(13) & chr(10);
		service &= chr(9) & "property " & dao & ";" & chr(13) & chr(10) & chr(13) & chr(10);

		service &= chr(9) & "function init( beanFactory ) {" & chr(13) & chr(10);
		service &= chr(9) & chr(9) & "variables.beanFactory = beanFactory;" & chr(13) & chr(10);
		service &= chr(9) & chr(9) & "return this;" & chr(13) & chr(10);
		service &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		service &= chr(9) & "function getAll() {" & chr(13) & chr(10);
		service &= chr(9) & chr(9) & "return get" & capitalizeString(dao) & "().getAll();" & chr(13) & chr(10);
		service &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		service &= chr(9) & "function getBeanById( required any id ) {" & chr(13) & chr(10);
		service &= chr(9) & chr(9) & "return get" & capitalizeString(dao) & "().getBeanById( id );" & chr(13) & chr(10);
		service &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		service &= chr(9) & "function getQueryBy( required struct rc ) {" & chr(13) & chr(10);
		service &= chr(9) & chr(9) & "return get" & capitalizeString(dao) & "().getQueryBy( argumentCollection=arguments.rc );" & chr(13) & chr(10);
		service &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		service &= chr(9) & "function create( required struct rc ) {" & chr(13) & chr(10);
		service &= chr(9) & chr(9) & "var bean = variables.beanFactory.getBean( '" & variables.table &"' );" & chr(13) & chr(10) & chr(13) & chr(10);

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(variables.tableColumns.is_primarykey[i] neq "yes"){
				service &= chr(9) & chr(9) & "bean.set" & capitalizeString(variables.tableColumns.column_name[i]) & "( rc." & variables.tableColumns.column_name[i] & " );" & chr(13) & chr(10);
			}
		}

		service &= chr(13) & chr(10);
		service &= chr(9) & chr(9) & "return get" & capitalizeString(dao) & "().create( bean );" & chr(13) & chr(10);
		service &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		service &= chr(9) & "function update( required struct rc ) {" & chr(13) & chr(10);
		service &= chr(9) & chr(9) & "var bean = variables.beanFactory.getBean('" & variables.table &"' );" & chr(13) & chr(10);

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			service &= chr(9) & chr(9) & "bean.set" & capitalizeString(variables.tableColumns.column_name[i]) & "( rc." & variables.tableColumns.column_name[i] & " );" & chr(13) & chr(10);
		}

		service &= chr(13) & chr(10);
		service &= chr(9) & chr(9) & "return get" & capitalizeString(dao) & "().update( bean );" & chr(13) & chr(10);
		service &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		service &= chr(9) & "function delete( required any bean ) {" & chr(13) & chr(10);
		service &= chr(9) & chr(9) & "return get" & dao & "().delete( bean );" & chr(13) & chr(10);
		service &= chr(9) & "}" & chr(13) & chr(10);

		service &= "}";

		return service;
	}

	// DAO Generator
	public string function generateDAO() {
		var dao = "component accessors=true {" & chr(13) & chr(10) & chr(13) & chr(10);
		dao &= chr(9) & "property " & variables.table & ";" & chr(13) & chr(10) & chr(13) & chr(10);

		//Init
		dao &= chr(9) & "function init( beanFactory, config ) {" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "variables.beanFactory = beanFactory;" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "variables.config = config;" & chr(13) & chr(10) & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "return this;" & chr(13) & chr(10);
		dao &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		//Get All
		dao &= chr(9) & "public any function getAll() {" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "var qry = new query();" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "qry.setDatasource(variables.config.getDatasource());" & chr(13) & chr(10) & chr(13) & chr(10);
		var sortOrder = '';
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('Name',variables.tableColumns.column_name[i]) neq 0) {
				if(sortOrder neq '') {
					sortOrder &= ', ';
				}
				sortOrder &= variables.tableColumns.column_name[i];
			}
		}
		dao &= chr(9) & chr(9) & "var sqlString = 'Select * from ##variables.config.getSchema()##." & variables.table;
		if(sortOrder neq '') {
			dao &= " order by " & sortOrder;
		}
		dao &= "';" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "qry.setSQL(sqlString);" & chr(13) & chr(10) & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "return qry.execute().getResult();" & chr(13) & chr(10);
		dao &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		//Get Bean by Id
		dao &= chr(9) & "public any function getBeanById( required any id ) {" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "var qry = new query();" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "qry.setDatasource(variables.config.getDatasource());" & chr(13) & chr(10) & chr(13) & chr(10);

		dao &= chr(9) & chr(9) & "var sqlString = 'select * from ##variables.config.getSchema()##.#variables.table# where #variables.pkField# = :#variables.pkField#';" & chr(13) & chr(10) & chr(13) & chr(10);

		dao &= chr(9) & chr(9) & "if(isValid('integer',id)) {" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "qry.addParam(name='" & variables.pkField & "',value='##arguments.id##',CFSQLTYPE='CF_SQL_INTEGER');" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "} else {" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "qry.addParam(name='" & variables.pkField & "',value='##arguments.id##',CFSQLTYPE='CF_SQL_VARCHAR');" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);


		dao &= chr(9) & chr(9) & "qry.setSQL(sqlString);" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "var result = qry.execute().getResult();" & chr(13) & chr(10) & chr(13) & chr(10);

		dao &= chr(9) & chr(9) & "var bean = variables.beanFactory.getBean('" & variables.table &"' );" & chr(13) & chr(10);

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			dao &= chr(9) & chr(9) & "bean.set" & capitalizeString(variables.tableColumns.column_name[i]) & "( result." & variables.tableColumns.column_name[i] & " );" & chr(13) & chr(10);
		}

		dao &= chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "return bean;" & chr(13) & chr(10);
		dao &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		// Get Query By
		dao &= chr(9) & "public any function getQueryBy() {" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "var qry = new query();" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "qry.setDatasource(variables.config.getDatasource());" & chr(13) & chr(10) & chr(13) & chr(10);

		dao &= chr(9) & chr(9) & "var sqlString = 'select * from ##variables.config.getSchema()##.#variables.table# where 1=1 and ';" & chr(13) & chr(10) & chr(13) & chr(10);

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			dao &= chr(9) & chr(9) & "if(structkeyexists(arguments, '" & variables.tableColumns.column_name[i] & "')){" & chr(13) & chr(10);
			dao &= chr(9) & chr(9) & chr(9) & "sqlString &= '" & variables.tableColumns.column_name[i] & " = :param" & i & "';" & chr(13) & chr(10);
			dao &= chr(9) & chr(9) & chr(9) & "qry.addParam(name='param" & i & "', value='##arguments." & variables.tableColumns.column_name[i] & "##',CFSQLTYPE='CF_SQL_";
			switch(variables.tableColumns.type_name[i]) {
				case "bit":
					dao &= "BIT');" & chr(13) & chr(10);
					break;
				case "char": case "nchar": case "uniqueidentifier": case "guid":
					dao &= "CHAR');" & chr(13) & chr(10);
					break;
				case "decimal": case "money": case "smallmoney":
					dao &= "DECIMAL');" & chr(13) & chr(10);
					break;
				case "float":
					dao &= "FLOAT');" & chr(13) & chr(10);
					break;
				case "int": case "integer": case "int identity":
					dao &= "INTEGER');" & chr(13) & chr(10);
					break;
				case "text": case "ntext":
					dao &= "LONGVARCHAR');" & chr(13) & chr(10);
					break;
				case "numeric":
					dao &= "NUMERIC');" & chr(13) & chr(10);
					break;
				case "real":
					dao &= "REAL');" & chr(13) & chr(10);
					break;
				case "smallint":
					dao &= "SMALLINT');" & chr(13) & chr(10);
					break;
				case "date":
					dao &= "DATE');" & chr(13) & chr(10);
					break;
				case "time":
					dao &= "TIME');" & chr(13) & chr(10);
					break;
				case "datetime":
					dao &= "TIMESTAMP');" & chr(13) & chr(10);
					break;
				case "smalldatetime":
					dao &= "TIMESTAMP');" & chr(13) & chr(10);
					break;
				case "tinyint":
					dao &= "TINYINT');" & chr(13) & chr(10);
					break;
				case "nvarchar":
					dao &= "VARCHAR');" & chr(13) & chr(10);
					break;
				default:
					dao &= "VARCHAR');" & chr(13) & chr(10);
					break;
			}

			dao &= chr(9) & chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);
		}

		dao &= chr(9) & chr(9) & "qry.setSQL(sqlString);" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "return qry.execute().getResult();" & chr(13) & chr(10);
		dao &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		// Create
		dao &= chr(9) & "public any function create( required any bean ) {" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "try {" & chr(13) & chr(10);

		dao &= chr(9) & chr(9) & chr(9) & "var qry = new query();" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "qry.setDatasource(variables.config.getDatasource());" & chr(13) & chr(10) & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var sqlString = 'Insert Into ##variables.config.getSchema()##.#variables.table#(";

		aList = "";
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(variables.tableColumns.is_primarykey[i] neq "yes"){
				aList &= variables.tableColumns.column_name[i] & ",";
			}
		}
		aList = mid(aList, 1, len(aList)-1);
		dao &= aList;
		dao &= ")'" & chr(13) & chr(10);

		dao &= chr(9) & chr(9) & chr(9) & chr(9) & "& ' values(";
		bList = "";
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(variables.tableColumns.column_name[i] neq variables.pkField){
				bList &= ":" & variables.tableColumns.column_name[i] & ",";
			}
		}
		bList = mid(bList, 1, len(bList)-1);
		dao &= bList;
		dao &= ")';" & chr(13) & chr(10);

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(variables.tableColumns.is_primarykey[i] neq "yes"){
				dao &= chr(9) & chr(9) & chr(9) & "qry.addParam(name='" & variables.tableColumns.column_name[i] & "', value='##arguments.bean.get" & capitalizeString(variables.tableColumns.column_name[i]) & "()##',CFSQLTYPE='CF_SQL_";
				switch(variables.tableColumns.type_name[i]) {
					case "bit":
						dao &= "BIT');" & chr(13) & chr(10);
						break;
					case "char": case "nchar": case "uniqueidentifier": case "guid":
						dao &= "CHAR');" & chr(13) & chr(10);
						break;
					case "decimal": case "money": case "smallmoney":
						dao &= "DECIMAL');" & chr(13) & chr(10);
						break;
					case "float":
						dao &= "FLOAT');" & chr(13) & chr(10);
						break;
					case "int": case "integer": case "int identity":
						dao &= "INTEGER');" & chr(13) & chr(10);
						break;
					case "text": case "ntext":
						dao &= "LONGVARCHAR');" & chr(13) & chr(10);
						break;
					case "numeric":
						dao &= "NUMERIC');" & chr(13) & chr(10);
						break;
					case "real":
						dao &= "REAL');" & chr(13) & chr(10);
						break;
					case "smallint":
						dao &= "SMALLINT');" & chr(13) & chr(10);
						break;
					case "date":
						dao &= "DATE');" & chr(13) & chr(10);
						break;
					case "time":
						dao &= "TIME');" & chr(13) & chr(10);
						break;
					case "datetime": case "smalldatetime":
						dao &= "TIMESTAMP');" & chr(13) & chr(10);
						break;
					case "tinyint":
						dao &= "TINYINT');" & chr(13) & chr(10);
						break;
					case "varchar": case "nvarchar":
						dao &= "VARCHAR');" & chr(13) & chr(10);
						break;
					default:
						dao &= "VARCHAR');" & chr(13) & chr(10);
						break;
				}
			}
		}

		dao &= chr(9) & chr(9) & chr(9) & "qry.setSQL(sqlString);" & chr(13) & chr(10) & chr(13) & chr(10);

		dao &= chr(9) & chr(9) & chr(9) & "var msg.id = qry.execute();" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var msg.text = 'Record inserted successfully.';" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var msg.type = 'success';" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "return msg;" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "} catch (any e) {" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var msg.text = 'An error has occured. The record was not inserted';" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var msg.type = 'error';" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var msg.result = e;" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "return msg;" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "}" & chr(13) & chr(10);
		dao &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		// Update
		dao &= chr(9) & "public any function update( required any bean ) {" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "try {" & chr(13) & chr(10);

		dao &= chr(9) & chr(9) & chr(9) & "var qry = new query();" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "qry.setDatasource(variables.config.getDatasource());" & chr(13) & chr(10) & chr(13) & chr(10);

		dao &= chr(9) & chr(9) & chr(9) & "var sqlString = 'Update ##variables.config.getSchema()##.#variables.table# Set'" & chr(13) & chr(10);

		uList = "";
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(variables.tableColumns.is_primarykey[i] eq false) {
				ulist &= chr(9) & chr(9) & chr(9) & chr(9) & "& ' #variables.tableColumns.column_name[i]# = :#variables.tableColumns.column_name[i]#,'" & chr(13) & chr(10);
			}
		}
		ulist = mid(ulist,1,len(ulist)-3);
		dao &= ulist & "'" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & chr(9) & "& ' where #variables.pkField# = :#variables.pkField#';" & chr(13) & chr(10);
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			dao &= chr(9) & chr(9) & chr(9) & "qry.addParam(name='" & variables.tableColumns.column_name[i] & "', value='##arguments.bean.get" & capitalizeString(variables.tableColumns.column_name[i]) & "()##',CFSQLTYPE='CF_SQL_";
			switch(variables.tableColumns.type_name[i]) {
				case "bit":
					dao &= "BIT');" & chr(13) & chr(10);
					break;
				case "char": case "nchar": case "uniqueidentifier": case "guid":
					dao &= "CHAR');" & chr(13) & chr(10);
					break;
				case "decimal": case "money": case "smallmoney":
					dao &= "DECIMAL');" & chr(13) & chr(10);
					break;
				case "float":
					dao &= "FLOAT');" & chr(13) & chr(10);
					break;
				case "int": case "integer": case "int identity":
					dao &= "INTEGER');" & chr(13) & chr(10);
					break;
				case "text": case "ntext":
					dao &= "LONGVARCHAR');" & chr(13) & chr(10);
					break;
				case "numeric":
					dao &= "NUMERIC');" & chr(13) & chr(10);
					break;
				case "real":
					dao &= "REAL');" & chr(13) & chr(10);
					break;
				case "smallint":
					dao &= "SMALLINT');" & chr(13) & chr(10);
					break;
				case "date":
					dao &= "DATE');" & chr(13) & chr(10);
					break;
				case "time":
					dao &= "TIME');" & chr(13) & chr(10);
					break;
				case "datetime": case "smalldatetime":
					dao &= "TIMESTAMP');" & chr(13) & chr(10);
					break;
				case "tinyint":
					dao &= "TINYINT');" & chr(13) & chr(10);
					break;
				case "varchar": case "nvarchar":
					dao &= "VARCHAR');" & chr(13) & chr(10);
					break;
				default:
					dao &= "VARCHAR');" & chr(13) & chr(10);
					break;
			}
		}

		dao &= chr(9) & chr(9) & chr(9) & "qry.setSQL(sqlString);" & chr(13) & chr(10) & chr(13) & chr(10);

		dao &= chr(9) & chr(9) & chr(9) & "qry.execute();" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var msg.text = 'Record updated successfully.';" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var msg.type = 'success';" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "return msg;" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "} catch (any e) {" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var msg.text = 'An error has occured. The record was not updated.';" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var msg.type = 'error';" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var msg.result = e;" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "return msg;" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "}" & chr(13) & chr(10);
		dao &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		// Delete
		dao &= chr(9) & "public any function delete( required any bean ) {" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "try {" & chr(13) & chr(10);

		dao &= chr(9) & chr(9) & chr(9) & "var qry = new query();" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "qry.setDatasource(variables.config.getDatasource());" & chr(13) & chr(10) & chr(13) & chr(10);

		dao &= chr(9) & chr(9) & chr(9) & "var sqlString = 'Delete from ##variables.config.getSchema()##.#variables.table# where #variables.pkField# = :pkValue';" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "qry.addParam(name='pkValue', value='##arguments.bean.get" & capitalizeString(variables.pkField) & "()##',CFSQLTYPE='CF_SQL_";
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(variables.tableColumns.Is_PrimaryKey[i]){
				switch(variables.tableColumns.type_name[i]) {
					case "bit":
						dao &= "BIT');" & chr(13) & chr(10);
						break;
					case "char": case "nchar": case "uniqueidentifier": case "guid":
						dao &= "CHAR');" & chr(13) & chr(10);
						break;
					case "decimal": case "money": case "smallmoney":
						dao &= "DECIMAL');" & chr(13) & chr(10);
						break;
					case "float":
						dao &= "FLOAT');" & chr(13) & chr(10);
						break;
					case "int": case "integer": case "int identity":
						dao &= "INTEGER');" & chr(13) & chr(10);
						break;
					case "text": case "ntext":
						dao &= "LONGVARCHAR');" & chr(13) & chr(10);
						break;
					case "numeric":
						dao &= "NUMERIC');" & chr(13) & chr(10);
						break;
					case "real":
						dao &= "REAL');" & chr(13) & chr(10);
						break;
					case "smallint":
						dao &= "SMALLINT');" & chr(13) & chr(10);
						break;
					case "date":
						dao &= "DATE');" & chr(13) & chr(10);
						break;
					case "time":
						dao &= "TIME');" & chr(13) & chr(10);
						break;
					case "datetime": case "smalldatetime":
						dao &= "TIMESTAMP');" & chr(13) & chr(10);
						break;
					case "tinyint":
						dao &= "TINYINT');" & chr(13) & chr(10);
						break;
					case "varchar": case "nvarchar":
						dao &= "VARCHAR');" & chr(13) & chr(10);
						break;
					default:
						dao &= "VARCHAR');" & chr(13) & chr(10);
						break;
				}
			}
		}
		dao &= chr(9) & chr(9) & chr(9) & "qry.setSQL(sqlString);" & chr(13) & chr(10) & chr(13) & chr(10);

		dao &= chr(9) & chr(9) & chr(9) & "qry.execute();" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var msg.text = 'Record deleted successfully.';" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var msg.type = 'success';" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "return msg;" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "} catch (any e) {" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var msg.text = 'An error has occured. The record was not deleted';" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var msg.type = 'error';" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "var msg.result = e;" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & chr(9) & "return msg;" & chr(13) & chr(10);
		dao &= chr(9) & chr(9) & "}" & chr(13) & chr(10);
		dao &= chr(9) & "}" & chr(13) & chr(10) & chr(13) & chr(10);

		// Create GUID
		// dao &= chr(9) & "private string function createNewID() {" & chr(13) & chr(10);
		// dao &= chr(9) & chr(9) & "var uuid = createUUID();" & chr(13) & chr(10);
		// dao &= chr(9) & chr(9) & "return uuid;" & chr(13) & chr(10);
		// dao &= chr(9) & "}" & chr(13) & chr(10);

		dao &= "}";

		return dao;
	}


	//Data Table Generator
	public string function generateDataTable(){
		var retVar = '<cfsavecontent variable="local.js">' & chr(13) & chr(10);
		retVar &= chr(9) & '<script language="JavaScript" type="text/javascript">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '$(document).ready(function() {' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & 'var #variables.table#Table = $("##' & variables.table & '").dataTable({' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '"bJQueryUI": true,' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '"sPaginationType": "full_numbers",' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '"sRowSelect": "single"' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '});' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & chr(9) & '$("##' & variables.table & ' tbody").delegate("tr", "click", function() {' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & 'var iPos = #variables.table#Table.fnGetPosition( this );' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & 'if(iPos!=null){' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & 'var aData = #variables.table#Table.fnGetData( iPos );//get data of the clicked row' & chr(13) & chr(10);
	    retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & 'var iId = aData[0];//get column data of the row' & chr(13) & chr(10);
	    retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<cfset redirectUrl = #apos##quot##apos# & ##buildURL("#variables.table#.viewEdit")## & #apos#&#variables.pkField#=#quot# + iId#apos#>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & 'document.location.href = ##redirectUrl##;' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '</cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '}' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '});' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & '});' & chr(13) & chr(10);
		retVar &= chr(9) & '</script>' & chr(13) & chr(10);
		retVar &= '</cfsavecontent>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= '<cfhtmlhead text="##local.js##">' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= '<div class="header">' & chr(13) & chr(10);
		retVar &= chr(9) & '<h1><cfoutput>##application.sitetitle##</cfoutput></h1>' & chr(13) & chr(10);
		retVar &= chr(9) & '<h2>#capitalizeString(variables.table)#</h2>' & chr(13) & chr(10);
		retVar &= '</div>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= '<div class="pure-g">' & chr(13) & chr(10);
		retVar &= chr(9) & '<div class="pure-u-1-1">' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & '<cfif structkeyexists(rc, "msg")>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<cfif rc.msg.type eq "success">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="ui-state-highlight ui-corner-all" style="margin-top: 20px; padding: 0 .7em;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) &  chr(9) & '<cfoutput>##rc.msg.text##</cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<cfelse>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="ui-state-error ui-corner-all" style="padding: 0 .7em;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<cfoutput>##rc.msg.text##</cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '</cfif>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '</cfif>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & '<a href="<cfoutput>##buildURL("#variables.table#.create")##</cfoutput>"><span class="fa fa-plus-circle"></span> Add A #nounForms.singularize(capitalizeString(variables.table))#</a>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '<br><br>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '<table id="#variables.table#" class="display hover">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<thead>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<tr align="left">' & chr(13) & chr(10);

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(variables.tableColumns.is_primarykey[i] eq true){
				retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<th class="hide_column">' & variables.tableColumns.column_name[i] & '</th>' & chr(13) & chr(10);
			} else {
				if(variables.tableColumns.column_size[i] lte 250) {
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<th>' & decamelizeString(variables.tableColumns.column_name[i]) & '</th>' & chr(13) & chr(10);
				}
			}
		}
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</tr>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '</thead>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<tbody>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<cfoutput query="rc.#variables.table#">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<tr>' & chr(13) & chr(10);

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(variables.tableColumns.is_primarykey[i] eq true){
				retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<td class="hide_column">##' & variables.tableColumns.column_name[i] & '##</td>' & chr(13) & chr(10);
			} else {
				if(variables.tableColumns.column_size[i] lte 250) {
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<td valign="top">';
					if(variables.tableColumns.type_name[i] eq "money") {
						retVar &= '##dollarformat(#variables.tableColumns.column_name[i]#)##';
					} else if(variables.tableColumns.type_name[i] eq "bit") {
						retVar &= '<cfif #variables.tableColumns.column_name[i]# eq 1>True<cfelse>False</cfif>';
					} else {
						retVar &= '##' & variables.tableColumns.column_name[i] & '##';
					}
					retVar &= '</td>' & chr(13) & chr(10);
				}
			}
		}

		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '</tr>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '</tbody>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '</table>' & chr(13) & chr(10);

		retVar &= chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= '</div>' & chr(13) & chr(10) & chr(13) & chr(10);

		return retVar;
	}

	//Create Form Generator
	public string function generateCreateForm(){
		var retVar = '<cfsavecontent variable="local.js">' & chr(13) & chr(10);
		retVar &= chr(9) & '<script language="JavaScript" type="text/javascript">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '$(document).ready(function() {' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '$(".datepicker").datepicker();' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '$(".spinner").spinner();' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '});' & chr(13) & chr(10);
		retVar &= chr(9) & '</script>' & chr(13) & chr(10);
		retVar &= '</cfsavecontent>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= '<cfhtmlhead text="##local.js##">' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= '<div class="header">' & chr(13) & chr(10);
		retVar &= chr(9) & '<h1><cfoutput>##application.sitetitle##</cfoutput></h1>' & chr(13) & chr(10);
		retVar &= chr(9) & '<h2>Create A #nounForms.singularize(capitalizeString(variables.table))#</h2>' & chr(13) & chr(10);
		retVar &= '</div>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= '<div class="pure-g">' & chr(13) & chr(10);
		retVar &= chr(9) & '<div class="pure-u-1-1">' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & '<cfif structkeyexists(rc, "msg")>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<cfif rc.msg.type eq "success">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="ui-state-highlight ui-corner-all" style="margin-top: 20px; padding: 0 .7em;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) &  chr(9) & '<cfoutput>##rc.msg.text##</cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<cfelse>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="ui-state-error ui-corner-all" style="padding: 0 .7em;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<cfoutput>##rc.msg.text##</cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '</cfif>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '</cfif>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & '<p style="font-size:9pt; font-weight:bold; margin-top:10px;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<a href="<cfoutput>##buildURL("#variables.table#.default")##</cfoutput>" style="text-decoration:none">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<span class="fa fa-arrow-left"></span> Return to #capitalizeString(variables.table)#' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '</a>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '</p>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & '<form action="<cfoutput>##buildURL("#variables.table#.create")##</cfoutput>" method="post" id="#variables.table#Form" class="pure-form pure-form-aligned">' & chr(13) & chr(10);

		for(i=1;i<=variables.tableColumns.recordCount;i++) {

			if(variables.tableColumns.is_primarykey[i] neq "yes") {
				retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="pure-control-group">' & chr(13) & chr(10);

				if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
					keyTable = mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3);
					pluralTable = nounForms.pluralize(keyTable);
					keyTableColumns = getColumns(pluralTable);
					keyTableTitle = "";
					for(x=1;x<=keyTableColumns.recordCount;x++) {
						if(keyTableColumns.Is_PrimaryKey[x] EQ true) {
							var pkKeyTable = keyTableColumns.column_name[x];
						}
						else if(Find('Name',keyTableColumns.column_name[x]) neq 0) {
							keyTableTitle &= keyTableColumns.column_name[x] & ' ';
						}
					}
					keyTableTitle = trim(keyTableTitle);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<label>#decamelizeString(nounForms.singularize(capitalizeString(keyTable)))#</label>' & chr(13) & chr(10);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<select name="#variables.tableColumns.column_name[i]#">' & chr(13) & chr(10);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<cfoutput query="rc.#pluralTable#">' & chr(13) & chr(10);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<option value="###pkKeyTable###">###keyTableTitle###</option>' & chr(13) & chr(10);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '</cfoutput>' & chr(13) & chr(10);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '</select>' & chr(13) & chr(10);
				} else {
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<label>#decamelizeString(nounForms.singularize(capitalizeString(variables.tableColumns.column_name[i])))#</label>' & chr(13) & chr(10);
					switch(variables.tableColumns.type_name[i]) {
						case "bit":
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="radio" value="1"/> True' & chr(13) & chr(10);
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="radio" value="0"/> False' & chr(13) & chr(10);
						break;

						case "char": case "nchar": case "varchar": case "varchar(max)": case "nvarchar": case "text": case "ntext":
							if(variables.tableColumns.column_size[i] lte 250) {
								retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" maxlength="50" />' & chr(13) & chr(10);
							} else {
								retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<textarea name="#variables.tableColumns.column_name[i]#" cols="48" rows="4"></ textarea>' & chr(13) & chr(10);
							}
						break;

						case "date": case "datetime": case "smalldatetime":
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" class="datepicker" />' & chr(13) & chr(10);
						break;

						case "int": case "integer": case "smallint": case "tinyint":
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" class="spinner" />' & chr(13) & chr(10);
						break;

						case "decimal": case "money": case "smallmoney": case "float": case "numeric": case "real":
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="20" />' & chr(13) & chr(10);
						break;

						default:
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" maxlength="50" />' & chr(13) & chr(10);
						break;
					}
				}
				retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10) & chr(13) & chr(10);

			}

		}

		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="pure-control-group">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<label>&nbsp;</label>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="btnSubmit" type="submit" value="Create This #nounForms.singularize(capitalizeString(variables.table))#" SubmitOnce="true" class="pure-button pure-button-primary" />' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '</form>' & chr(13) & chr(10);
		retVar &= chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= '</div>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= '<script type="text/javascript">' & chr(13) & chr(10);
		retVar &= chr(9) & '$( "##' & variables.table & 'Form" ).validate({' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & 'rules: {' & chr(13) & chr(10);

		for(i=1;i<=variables.tableColumns.recordCount;i++) {

			if(variables.tableColumns.is_primarykey[i] neq "yes") {
				retVar &= chr(9) & chr(9) & chr(9) & '#variables.tableColumns.column_name[i]#{ ';

				if(variables.tableColumns.is_nullable[i] eq "no"){
					retVar &= 'required:true';
				} else {
					retVar &= 'required:false';
				}

				switch(variables.tableColumns.type_name[i]) {

					case "date": case "datetime": case "smalldatetime":
					retVar &= ', date: true';
					break;

					case "int": case "integer": case "smallint": case "tinyint":
					retVar &= ', digits: true';
					break;

					case "decimal": case "money": case "smallmoney": case "float": case "numeric": case "real":
					retVar &= ', number: true';
					break;

				}

				retVar &= ' },' & chr(13) & chr(10);

			}

		}

		retVar = mid(retVar,1,len(retVar)-3);
		retVar &= '}' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '}' & chr(13) & chr(10);
		retVar &= chr(9) & '});' & chr(13) & chr(10);
		retVar &= '</script>';

		return retVar;
	}


	//Update Form Generator
	public string function generateUpdateForm(){
		var retVar = '<cfsavecontent variable="local.js">' & chr(13) & chr(10);
		retVar &= chr(9) & '<script language="JavaScript" type="text/javascript">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '$(document).ready(function() {' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '$(".datepicker").datepicker();' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '$(".spinner").spinner();' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '});' & chr(13) & chr(10);
		retVar &= chr(9) & '</script>' & chr(13) & chr(10);
		retVar &= '</cfsavecontent>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= '<cfhtmlhead text="##local.js##">' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= '<div class="header">' & chr(13) & chr(10);
		retVar &= chr(9) & '<h1><cfoutput>##application.sitetitle##</cfoutput></h1>' & chr(13) & chr(10);
		retVar &= chr(9) & '<h2><cfoutput>';
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('Name', variables.tableColumns.column_name[i]) neq 0) {
			  retVar &= '##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## ';
			 }
		}
		retVar &= '</cfoutput></h2>' & chr(13) & chr(10);
		retVar &= '</div>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= '<div class="pure-g">' & chr(13) & chr(10);
		retVar &= chr(9) & '<div class="pure-u-1-1">' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & '<cfif structkeyexists(rc, "msg")>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<cfif rc.msg.type eq "success">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="ui-state-highlight ui-corner-all" style="margin-top: 20px; padding: 0 .7em;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) &  chr(9) & '<cfoutput>##rc.msg.text##</cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<cfelse>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="ui-state-error ui-corner-all" style="padding: 0 .7em;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<cfoutput>##rc.msg.text##</cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '</cfif>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '</cfif>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & '<p style="font-size:9pt; font-weight:bold; margin-top:10px;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<a href="<cfoutput>##buildURL("#variables.table#.default")##</cfoutput>" style="text-decoration:none">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<span class="fa fa-arrow-left"></span> Return to #capitalizeString(variables.table)#' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '</a>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '</p>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & '<cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '<form action="##buildURL("#variables.table#.update")##" method="post" id="#variables.table#Form" class="pure-form pure-form-aligned">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<fieldset>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<legend>Update ##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##</legend>' & chr(13) & chr(10) & chr(13) & chr(10);

		for(i=1;i<=variables.tableColumns.recordCount;i++) {

			if(variables.tableColumns.is_primarykey[i] neq "yes") {

				retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="pure-control-group">' & chr(13) & chr(10);

				if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
					keyTable = mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3);
					pluralTable = nounForms.pluralize(keyTable);
					keyTableColumns = getColumns(pluralTable);
					keyTableTitle = "";
					for(x=1;x<=keyTableColumns.recordCount;x++) {
						if(keyTableColumns.Is_PrimaryKey[x] EQ true) {
							var pkKeyTable = keyTableColumns.column_name[x];
						}
						else if(Find('Name',keyTableColumns.column_name[x]) neq 0) {
							keyTableTitle &= keyTableColumns.column_name[x] & ' ';
						}
					}
					keyTableTitle = trim(keyTableTitle);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<label>#decamelizeString(nounForms.singularize(capitalizeString(keyTable)))#</label>' & chr(13) & chr(10);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<select name="#variables.tableColumns.column_name[i]#">' & chr(13) & chr(10);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<cfoutput query="rc.#pluralTable#">' & chr(13) & chr(10);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<option value="###pkKeyTable###"<cfif ###pkKeyTable### eq ##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##>selected="selected"</cfif>>###keyTableTitle###</option>' & chr(13) & chr(10);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '</cfoutput>' & chr(13) & chr(10);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '</select>' & chr(13) & chr(10);
				} else {
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<label>#decamelizeString(nounForms.singularize(capitalizeString(variables.tableColumns.column_name[i])))#</label>' & chr(13) & chr(10);
					switch(variables.tableColumns.type_name[i]) {
						case "bit":
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="radio" value="1" <cfif ##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## eq 1>checked="checked"</cfif>/> True' & chr(13) & chr(10);
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="radio" value="0" <cfif ##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## eq 0>checked="checked"</cfif>/> False' & chr(13) & chr(10);
						break;

						case "char": case "nchar": case "varchar": case "varchar(max)": case "nvarchar": case "text": case "ntext":
							if(variables.tableColumns.column_size[i] lte 250) {
								retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" maxlength="50" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & chr(13) & chr(10);
							} else {
								retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<textarea name="#variables.tableColumns.column_name[i]#" cols="48" rows="4">##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##"</ textarea>' & chr(13) & chr(10);
							}
						break;

						case "date": case "datetime": case "smalldatetime":
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" class="datepicker" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & chr(13) & chr(10);
						break;

						case "int": case "integer": case "smallint": case "tinyint":
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" class="spinner" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & chr(13) & chr(10);
						break;

						case "decimal": case "money": case "smallmoney": case "float": case "numeric": case "real":
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="20" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & chr(13) & chr(10);
						break;

						default:
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" maxlength="50" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & chr(13) & chr(10);
						break;
					}
				}
				retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10) & chr(13) & chr(10);

			}

		}

		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="pure-control-group">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<label>&nbsp;</label>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.pkField#" type="hidden" value="##rc.#variables.table#Bean.get#capitalizeString(variables.pkField)#()##" />' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="btnSubmit" type="submit" value="Submit" SubmitOnce="true" class="pure-button pure-button-primary" />' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '</fieldset>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '</form>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '</cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= '</div>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= '<script type="text/javascript">' & chr(13) & chr(10);
		retVar &= chr(9) & '$( "##' & variables.table & 'Form" ).validate({' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & 'rules: {' & chr(13) & chr(10);

		for(i=1;i<=variables.tableColumns.recordCount;i++) {

			if(variables.tableColumns.is_primarykey[i] neq "yes") {
				retVar &= chr(9) & chr(9) & chr(9) & '#variables.tableColumns.column_name[i]#{ ';

				if(variables.tableColumns.is_nullable[i] eq "no"){
					retVar &= 'required:true';
				} else {
					retVar &= 'required:false';
				}

				switch(variables.tableColumns.type_name[i]) {

					case "date": case "datetime": case "smalldatetime":
					retVar &= ', date: true';
					break;

					case "int": case "integer": case "smallint": case "tinyint":
					retVar &= ', digits: true';
					break;

					case "decimal": case "money": case "smallmoney": case "float": case "numeric": case "real":
					retVar &= ', number: true';
					break;

				}

				retVar &= ' },' & chr(13) & chr(10);

			}

		}

		retVar = mid(retVar,1,len(retVar)-3);
		retVar &= '}' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '}' & chr(13) & chr(10);
		retVar &= chr(9) & '});' & chr(13) & chr(10);
		retVar &= '</script>';

		return retVar;
	}

	//View Generator
	public string function generateView() {
		var retVar = '<div class="header">' & chr(13) & chr(10);
		retVar &= chr(9) & '<h1><cfoutput>##application.sitetitle##</cfoutput></h1>' & chr(13) & chr(10);
		retVar &= chr(9) & '<h2><cfoutput>';
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('Name', variables.tableColumns.column_name[i]) neq 0) {
			  retVar &= '##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## ';
			 }
		}
		retVar &= '</cfoutput></h2>' & chr(13) & chr(10);
		retVar &= '</div>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= '<div class="pure-g">' & chr(13) & chr(10);
		retVar &= chr(9) & '<div class="pure-u-1-1">' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & '<cfif structkeyexists(rc, "msg")>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<cfif rc.msg.type eq "success">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="ui-state-highlight ui-corner-all" style="margin-top: 20px; padding: 0 .7em;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) &  chr(9) & '<cfoutput>##rc.msg.text##</cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<cfelse>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="ui-state-error ui-corner-all" style="padding: 0 .7em;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<cfoutput>##rc.msg.text##</cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '</cfif>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '</cfif>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & '<cfoutput>' & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & chr(9) & '<p style="font-size:9pt; font-weight:bold; margin-top:10px;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<a href="##buildURL(#variables.apos##variables.table#.default#variables.apos#)##" style="text-decoration:none">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<span class="fa fa-arrow-left"></span> Return to #variables.table#' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</a> | ' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<a href="##buildURL(#variables.apos##variables.table#.update?#variables.pkField#=##rc.#variables.table#Bean.get#capitalizeString(variables.pkField)#()###variables.apos#)##" style="text-decoration: none;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<span class="fa fa-pencil-square-o"></span> Update This #nounForms.singularize(capitalizeString(variables.table))#' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</a> |' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<a href="##buildURL(#variables.apos##variables.table#.delete?#variables.pkField#=##rc.#variables.table#Bean.get#capitalizeString(variables.pkField)#()###variables.apos#)##" onclick="javascript:return confirm(#variables.apos#Are you sure you want to delete ';
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('Name', variables.tableColumns.column_name[i]) neq 0) {
			  retVar &= '##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## ';
			 }
		}
		retVar &= '#variables.apos#)" style="text-decoration: none;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<span class="fa fa-minus-circle"></span> Delete This #nounForms.singularize(capitalizeString(variables.table))#' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</a>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '</p>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & chr(9) & '<div class="pure-g">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<table class="pure-table pure-u-1-1">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<tbody>' & chr(13) & chr(10);

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
		if(variables.tableColumns.is_primarykey[i] neq "yes") {

		if(i mod 2 eq 1){
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<tr class="pure-table-odd">' & chr(13) & chr(10);
		} else {
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<tr>' & chr(13) & chr(10);
		}
		if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
			fieldLabel = mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3);
		} else {
			fieldLabel = variables.tableColumns.column_name[i];
		}
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<td><strong>#decamelizeString(nounForms.singularize(capitalizeString(fieldLabel)))#</strong></td>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<td>';
		if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
		retVar &= '##rc.#nounForms.singularize(variables.table)##nounForms.singularize(capitalizeString(fieldLabel))###';
		} else if(variables.tableColumns.type_name[i] eq "money") {
		retVar &= '##dollarformat(rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#())##';
		} else if(variables.tableColumns.type_name[i] eq "bit") {
		retVar &= '<cfif rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#() eq 1>True<cfelse>False</cfif>';
		} else if(Find('Email', variables.tableColumns.column_name[i]) neq 0) {
		retVar &= '<a href="mailto:##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##">##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##</a>';
		} else if(Find('Url', variables.tableColumns.column_name[i]) neq 0) {
		retVar &= '<a href="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" target="_blank">##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##</a>';
		} else {
		retVar &= '##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##';
		}
		retVar &= '</td>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '</tr>' & chr(13) & chr(10);

			}
		}
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '</tbody>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</table>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '</cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= '</div>' & chr(13) & chr(10);

		return retVar;
	}


	//ViewEdit Generator
	public string function generateViewEdit() {
		var retVar = '<cfsavecontent variable="local.js">' & chr(13) & chr(10);
		retVar &= chr(9) & '<script language="JavaScript" type="text/javascript">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '$(document).ready(function() {' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '$(".datepicker").datepicker();' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '$(".spinner").spinner();' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '});' & chr(13) & chr(10);
		retVar &= chr(9) & '</script>' & chr(13) & chr(10);
		retVar &= '</cfsavecontent>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= '<cfhtmlhead text="##local.js##">' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= '<div class="header">' & chr(13) & chr(10);
		retVar &= chr(9) & '<h1><cfoutput>##application.sitetitle##</cfoutput></h1>' & chr(13) & chr(10);
		retVar &= chr(9) & '<h2><cfoutput>';
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('Name', variables.tableColumns.column_name[i]) neq 0) {
			  retVar &= '##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## ';
			 }
		}
		retVar &= '</cfoutput></h2>' & chr(13) & chr(10);
		retVar &= '</div>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= '<div class="pure-g">' & chr(13) & chr(10);
		retVar &= chr(9) & '<div class="pure-u-1-1">' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & '<cfif structkeyexists(rc, "msg")>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<cfif rc.msg.type eq "success">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="ui-state-highlight ui-corner-all" style="margin-top: 20px; padding: 0 .7em;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) &  chr(9) & '<cfoutput>##rc.msg.text##</cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<cfelse>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="ui-state-error ui-corner-all" style="padding: 0 .7em;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<cfoutput>##rc.msg.text##</cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '</cfif>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '</cfif>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & '<cfoutput>' & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & chr(9) & '<p style="font-size:9pt; font-weight:bold; margin-top:10px;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<a href="##buildURL(#variables.apos##variables.table#.default#variables.apos#)##" style="text-decoration:none">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<span class="fa fa-arrow-left"></span> Return to #variables.table#' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</a> | ' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<a href="##buildURL(#variables.apos##variables.table#.delete?#variables.pkField#=##rc.#variables.table#Bean.get#capitalizeString(variables.pkField)#()###variables.apos#)##" onclick="javascript:return confirm(#variables.apos#Are you sure you want to delete ';
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('Name', variables.tableColumns.column_name[i]) neq 0) {
			  retVar &= '##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## ';
			 }
		}
		retVar &= '#variables.apos#)" style="text-decoration: none;">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<span class="fa fa-minus-circle"></span> Delete This #nounForms.singularize(capitalizeString(variables.table))#' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</a>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '</p>' & chr(13) & chr(10) & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & chr(9) & '<div id="viewInfo" class="pure-g">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<button id="showUpdate" class="pure-u-1-1 pure-button pure-button-primary">Update This #nounForms.singularize(capitalizeString(variables.table))#</button>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<br><br>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<table class="pure-table pure-u-1-1">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<tbody>' & chr(13) & chr(10);

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
		if(variables.tableColumns.is_primarykey[i] neq "yes") {

		if(i mod 2 eq 1){
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<tr class="pure-table-odd">' & chr(13) & chr(10);
		} else {
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<tr>' & chr(13) & chr(10);
		}
		if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
			fieldLabel = mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3);
		} else {
			fieldLabel = variables.tableColumns.column_name[i];
		}
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<td><strong>#decamelizeString(nounForms.singularize(capitalizeString(fieldLabel)))#</strong></td>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<td>';
		if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
		retVar &= '##rc.#nounForms.singularize(variables.table)##nounForms.singularize(capitalizeString(fieldLabel))###';
		} else if(variables.tableColumns.type_name[i] eq "money") {
		retVar &= '##dollarformat(rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#())##';
		} else if(variables.tableColumns.type_name[i] eq "bit") {
		retVar &= '<cfif rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#() eq 1>True<cfelse>False</cfif>';
		} else if(Find('Email', variables.tableColumns.column_name[i]) neq 0) {
		retVar &= '<a href="mailto:##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##">##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##</a>';
		} else if(Find('Url', variables.tableColumns.column_name[i]) neq 0) {
		retVar &= '<a href="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" target="_blank">##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##</a>';
		} else {
		retVar &= '##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##';
		}
		retVar &= '</td>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '</tr>' & chr(13) & chr(10);

			}
		}
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '</tbody>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</table>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<div id="updateInfo">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<button id="showView" class="pure-u-1-1 pure-button pure-button-primary">Return To View This #nounForms.singularize(capitalizeString(variables.table))#</button>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<br><br>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '<cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '<form action="##buildURL("#variables.table#.viewedit")##" method="post" id="#variables.table#Form" class="pure-form pure-form-aligned">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '<fieldset>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<legend>Update #nounForms.singularize(capitalizeString(variables.table))#</legend>' & chr(13) & chr(10) & chr(13) & chr(10);

		for(i=1;i<=variables.tableColumns.recordCount;i++) {

			if(variables.tableColumns.is_primarykey[i] neq "yes") {

				retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="pure-control-group">' & chr(13) & chr(10);
				if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
					fieldLabel = mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3);
				} else {
					fieldLabel = variables.tableColumns.column_name[i];
				}
				retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<label>#decamelizeString(nounForms.singularize(capitalizeString(fieldLabel)))#</label>' & chr(13) & chr(10);
				if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
					keyTable = mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3);
					pluralTable = nounForms.pluralize(keyTable);
					keyTableColumns = getColumns(pluralTable);
					keyTableTitle = "";
					for(x=1;x<=keyTableColumns.recordCount;x++) {
						if(keyTableColumns.Is_PrimaryKey[x] EQ true) {
							var pkKeyTable = keyTableColumns.column_name[x];
						}
						else if(Find('Name',keyTableColumns.column_name[x]) neq 0) {
							keyTableTitle &= keyTableColumns.column_name[x] & ' ';
						}
					}
					keyTableTitle = trim(keyTableTitle);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<label>#decamelizeString(nounForms.singularize(capitalizeString(keyTable)))#</label>' & chr(13) & chr(10);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<select name="#variables.tableColumns.column_name[i]#">' & chr(13) & chr(10);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<cfoutput query="rc.#pluralTable#">' & chr(13) & chr(10);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<option value="###pkKeyTable###"<cfif ###pkKeyTable### eq ##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##>selected="selected"</cfif>>###keyTableTitle###</option>' & chr(13) & chr(10);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '</cfoutput>' & chr(13) & chr(10);
					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '</select>' & chr(13) & chr(10);
				} else {
					switch(variables.tableColumns.type_name[i]) {
						case "bit":
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="radio" value="1" <cfif ##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## eq 1>checked="checked"</cfif>/> True' & chr(13) & chr(10);
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="radio" value="0" <cfif ##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## eq 0>checked="checked"</cfif>/> False' & chr(13) & chr(10);
						break;

						case "char": case "nchar": case "varchar": case "varchar(max)": case "nvarchar": case "text": case "ntext":
							if(variables.tableColumns.column_size[i] lte 250) {
								retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" maxlength="50" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & chr(13) & chr(10);
							} else {
								retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<textarea name="#variables.tableColumns.column_name[i]#" cols="48" rows="4">##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##"</ textarea>' & chr(13) & chr(10);
							}
						break;

						case "date": case "datetime": case "smalldatetime":
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" class="datepicker" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & chr(13) & chr(10);
						break;

						case "int": case "integer": case "smallint": case "tinyint":
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" class="spinner" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & chr(13) & chr(10);
						break;

						case "decimal": case "money": case "smallmoney": case "float": case "numeric": case "real":
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="20" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & chr(13) & chr(10);
						break;

						default:
						retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" maxlength="50" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & chr(13) & chr(10);
						break;

					}

					retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10) & chr(13) & chr(10);
					}
				}
		}

		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '<div class="pure-control-group">' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<label>&nbsp;</label>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="#variables.pkField#" type="hidden" value="##rc.#variables.table#Bean.get#capitalizeString(variables.pkField)#()##" />' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & chr(9) &'<input name="btnSubmit" type="submit" value="Update This #nounForms.singularize(capitalizeString(variables.table))#" SubmitOnce="true" class="pure-button pure-button-primary" />' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '</fieldset>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '</form>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '</cfoutput>' & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '</cfoutput>' & chr(13) & chr(10);
		retVar &= chr(9) & '</div>' & chr(13) & chr(10);
		retVar &= '</div>' & chr(13) & chr(10);

		retVar &= '<script type="text/javascript">' & chr(13) & chr(10);
		retVar &= chr(9) & '$(document).ready(function() {	' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '$("##updateInfo").hide();' & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & '$("##showUpdate").click(function(){' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '$("##updateInfo").show();' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '$("##viewInfo").hide();' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '});' & chr(13) & chr(10);

		retVar &= chr(9) & chr(9) & '$("##showView").click(function(){' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '$("##updateInfo").hide();' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & chr(9) & '$("##viewInfo").show();' & chr(13) & chr(10);
		retVar &= chr(9) & chr(9) & '});' & chr(13) & chr(10);

		retVar &= chr(9) & '});' & chr(13) & chr(10);
		retVar &= '</script>';

		return retVar;
	}
}
