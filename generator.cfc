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
			variables.columnNames = valueList(variables.tableColumns.column_name);
			variables.pkField = variables.tableColumns.column_name[1];

			for(i=1;i<=variables.tableColumns.recordCount;i++) {
				if(variables.tableColumns.Is_PrimaryKey[i]) {
					variables.pkField = variables.tableColumns.column_name[i];
				}
			}
		}

		variables.nounForms = CreateObject("component", "nounForms").init();

	  	variables.apos = "'";
	  	variables.quot = '"';
	  	variables.tab = chr(9);
	  	variables.crlf = chr(13) & chr(10);

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
		//return new dbinfo(datasource=variables.dsn).columns(table=arguments.table);
		var q = new query();
		q.setDatasource(variables.dsn);
		q.setSQL("
			select isNull(c.character_octet_length,0) as char_octet_length
					,c.column_default as column_default_value
					,c.column_name
					,c.character_maximum_length as column_size
					,isNull(c.datetime_precision,0) as decimal_digits
					,CASE WHEN tc.CONSTRAINT_TYPE = 'FOREIGN KEY' THEN 1 ELSE 0 END as is_foreignKey
					,c.is_nullable
					,CASE WHEN tc.CONSTRAINT_TYPE = 'PRIMARY KEY' THEN 1 ELSE 0 END as is_primaryKey
					,c.ordinal_position
					,'' as referenced_primarykey
					,'' as referenced_primarykey_table
					,'' as remarks
					,c.data_type as type_name
					,c.table_schema
			FROM INFORMATION_SCHEMA.COLUMNS c
			LEFT OUTER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KU on c.TABLE_CATALOG = ku.TABLE_CATALOG
																	and c.TABLE_SCHEMA = ku.TABLE_SCHEMA
																	and c.TABLE_NAME = ku.TABLE_NAME
																	and c.COLUMN_NAME = ku.COLUMN_NAME
			LEFT OUTER join INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc on ku.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
			WHERE c.TABLE_NAME=:tableName

		");
		q.addParam(name='tableName', value='#arguments.table#',CFSQLTYPE='CF_SQL_VARCHAR');
		return q.execute().getResult();
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
		var retVar = 'component extends="frameworks.org.corfield.framework" {' & crlf & crlf;
			retVar &= tab & 'this.datasource = "#variables.dsn#";' & crlf;
			retVar &= tab & 'this.sessionmanagement = true;' & crlf;
			retVar &= tab & 'this.clientManagement  = true;' & crlf;
			retVar &= tab & 'this.scriptprotect = true;' & crlf;
			retVar &= tab & 'this.sitetitle = "#variables.sitetitle#";' & crlf & crlf;

			retVar &=  tab & 'variables.framework = {' & crlf;
				retVar &=  tab & tab & 'action = "action",' & crlf;
				retVar &=  tab & tab & 'defaultSection = "main",' & crlf;
				retVar &=  tab & tab & 'defaultItem = "default",' & crlf;
				retVar &=  tab & tab & 'default = "main.default",' & crlf;
				retVar &=  tab & tab & 'error = "main.error",' & crlf;
				retVar &=  tab & tab & 'reload = "reload",' & crlf;
				retVar &=  tab & tab & 'password = "true",' & crlf;
				retVar &=  tab & tab & '// Reload application on every request set to true for development purposes' & crlf;
				retVar &=  tab & tab & '// Strongly recommended to change to false before pushing to production' & crlf;
				retVar &=  tab & tab & 'reloadApplicationOnEveryRequest = true' & crlf;
			retVar &=  tab & '};' & crlf & crlf;

			retVar &=  tab & 'function setupApplication() {' & crlf;
        		retVar &=  tab & tab & 'var beanFactory = new frameworks.org.corfield.ioc( "model" );' & crlf;
        		retVar &=  tab & tab & 'setBeanFactory( beanFactory );' & crlf & crlf;

				retVar &=  tab & tab & 'Application.Datasource = this.datasource;' & crlf;
				retVar &=  tab & tab & 'Application.SiteTitle = this.sitetitle;' & crlf;
			retVar &=  tab & '}' & crlf;
		retVar &= '}';

		return retVar;
	}

	// Default Layout Generator
	public string function generateDefaultLayout() {
		var retVar = '<!DOCTYPE html>' & crlf;
			retVar &=  '<html lang="en">' & crlf;
			retVar &=  '<head>' & crlf;
			retVar &=  tab & '<meta charset="utf-8">' & crlf;
			retVar &=  tab & '<meta name="viewport" content="width=device-width, initial-scale=1.0">' & crlf;
			retVar &=  tab & '<title><cfoutput>Title</cfoutput></title>' & crlf & crlf;

			retVar &=  tab & '<script src="//code.jquery.com/jquery-1.10.2.js"></script>' & crlf;
			retVar &=  tab & '<script src="//code.jquery.com/ui/1.11.0/jquery-ui.js"></script>' & crlf;
			retVar &=  tab & '<script src="//ajax.aspnetcdn.com/ajax/jquery.validate/1.13.0/jquery.validate.js"></script>' & crlf;
			retVar &=  tab & '<script src="//ajax.aspnetcdn.com/ajax/jquery.validate/1.13.0/additional-methods.min.js"></script>' & crlf;
			retVar &=  tab & '<script src="//cdn.datatables.net/1.10.1/js/jquery.dataTables.min.js"></script>' & crlf & crlf;

			retVar &=  tab & '<link href="//ajax.aspnetcdn.com/ajax/jquery.ui/1.10.1/themes/redmond/jquery-ui.min.css" rel="stylesheet" />' & crlf;
			retVar &=  tab & '<link href="css/demo_table_jui.css" rel="stylesheet" />' & crlf;
			retVar &=  tab & '<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet" />' & crlf & crlf;

			retVar &=  tab & '<link href="http://yui.yahooapis.com/pure/0.5.0/pure-min.css" rel="stylesheet" />' & crlf & crlf;

 			retVar &=  tab & '<!--[if lte IE 8]>' & crlf;
			retVar &=  tab & tab & '<link rel="stylesheet" href="css/layouts/side-menu-old-ie.css">' & crlf;
			retVar &=  tab & '<![endif]-->' & crlf;
			retVar &=  tab & '<!--[if gt IE 8]><!-->' & crlf;
			retVar &=  tab & tab & '<link rel="stylesheet" href="css/layouts/side-menu.css">' & crlf;
 			retVar &=  tab & '<!--<![endif]-->' & crlf;
			retVar &=  tab & tab & '<link rel="stylesheet" href="css/styles.css">' & crlf;
			retVar &= '</head>' & crlf & crlf;

			retVar &= '<body>' & crlf;
			retVar &=  tab & '<div id="layout">' & crlf;
			retVar &=  tab & tab & '<!-- Menu toggle -->' & crlf;
			retVar &=  tab & tab & '<a href="##menu" id="menuLink" class="menu-link">' & crlf;
			retVar &=  tab & tab & tab & '<!-- Hamburger icon -->' & crlf;
			retVar &=  tab & tab & tab & '<span></span>' & crlf;
			retVar &=  tab & tab & '</a>' & crlf & crlf;

			retVar &=  tab & tab & '<div id="menu">' & crlf;
			retVar &=  tab & tab & tab & '<div class="pure-menu pure-menu-open">' & crlf;
			retVar &=  tab & tab & tab & tab & '<cfoutput><a class="pure-menu-heading" href="##buildURL(#variables.apos#main.default#variables.apos#)##">Title</a></cfoutput>' & crlf & crlf;

			retVar &=  tab & tab & tab & tab & '<ul>' & crlf;
			retVar &=  tab & tab & tab & tab & tab & '<cfoutput>' & crlf;
			retVar &=  tab & tab & tab & tab & tab & '<li><a href="##buildURL(#variables.apos#main.default#variables.apos#)##">Home</a></li>' & crlf;

			for(i=1;i<=listlen(variables.tables);i++) {
				retVar &=  tab & tab & tab & tab & tab & '<li><a href="##buildURL(#variables.apos##listgetat(variables.tables,i)#.default#variables.apos#)##">#capitalizeString(listgetat(variables.tables,i))#</a></li>' & crlf;
			}

			retVar &=  tab & tab & tab & tab & tab & '</cfoutput>' & crlf;
			retVar &=  tab & tab & tab & tab & '</ul>' & crlf;
			retVar &=  tab & tab & tab & '</div>' & crlf;
			retVar &=  tab & tab & '</div>' & crlf & crlf;

			retVar &=  tab & tab & '<div id="main">' & crlf;
			retVar &=  tab & tab & '<cfoutput>##body##</cfoutput>' & crlf;
			retVar &=  tab & tab & '</div>' & crlf;
			retVar &=  tab & '</div>' & crlf;
			retVar &= '</body>' & crlf;
			retVar &= '</html>';

		return retVar;
	}

	// Table Config Generator
	public string function generateBean() {
		var qColumns = getColumns(variables.table);
		var bean = "component accessors=true extends='#variables.sitetitle#.common.baseClasses.baseBean' {" & crlf;
		for(i=1;i<=qColumns.recordCount;i++) {
			var line = tab & "property ";
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
			line &= qColumns.column_name[i] & ";" & crlf ;
			bean &= line;
		}
		bean &= "}";

		return bean;
	}

	// Controller Generator
	public string function generateController() {
		var service = variables.table & "Service";
		var serviceCall = "variables." & service;

		var controller = "component persistent='false' accessors='true' output='false' extends='controller' {" & crlf & crlf;
		controller &= tab & "property " & service & ";" & crlf;
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
				keyTable = nounForms.pluralize(mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3));
				controller &= tab & "property " & keyTable & "Service;" & crlf;
			}
		}
		// controller &= crlf & tab & "function init( fw ) {" & crlf;
		// controller &= tab & tab & "variables.fw = fw;" & crlf;
		// controller &= tab & "}" & crlf & crlf;

		controller &= crlf & tab & "public any function before(required struct rc) {" & crlf;
		controller &= tab & tab & "#serviceCall#.setDatasource();" & crlf;
		controller &= tab & tab & "#serviceCall#.setSchema();" & crlf;
		controller &= tab & tab & "super.before(rc);" & crlf;
		controller &= tab & "}" & crlf & crlf;

		controller &= crlf;
		controller &= tab & "// *********************************  PAGES  *******************************************";
		controller &= crlf;

		controller &= tab & "public any function default(required struct rc ) {" & crlf;
		controller &= tab & tab & "rc." & variables.table & " = " & serviceCall & ".getAll();" & crlf;
		controller &= tab & "}" & crlf & crlf;

		controller &= tab & "public void function create(required struct rc ) {" & crlf;
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
				keyTable = nounForms.pluralize(mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3));
				controller &= tab & tab & "rc." & keyTable & " = variables." & keyTable & "Service.getAll();" & crlf;
			}
		}
		controller &= tab & tab & "if(structKeyExists(rc, 'btnSubmit')) {" & crlf;
		controller &= tab & tab & tab & "rc.msg = " & serviceCall & ".create( rc );" & crlf;
		controller &= tab & tab & "}" & crlf;
		controller &= tab & "}" & crlf & crlf;

		controller &= tab & "public any function view(required struct rc ) {" & crlf;
		controller &= tab & tab & "rc." & variables.table & "Bean = " & serviceCall & ".getBeanById(rc." & variables.pkField & ");" & crlf;
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
				keyTable = mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3);
				controller &= tab & tab & "rc." & keyTable & " = variables." & keyTable & "Service.getAll();" & crlf;
				controller &= tab & tab & "rc.#nounForms.singularize(variables.table)##capitalizeString(nounForms.singularize(keyTable))# = variables.#keyTable#Service.getBeanById(rc.#keyTable#Bean.get#capitalizeString(keyTable)#_fk());" & crlf;
			}
		}
		controller &= tab & "}" & crlf & crlf;

		controller &= tab & "public any function viewEdit(required struct rc ) {" & crlf;
		controller &= tab & tab & "rc." & variables.table & "Bean = " & serviceCall & ".getBeanById(rc." & variables.pkField & ");" & crlf;
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
				keyTable = mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3);
				controller &= tab & tab & "rc." & keyTable & " = variables." & keyTable & "Service.getAll();" & crlf;
				controller &= tab & tab & "rc.#nounForms.singularize(variables.table)##capitalizeString(nounForms.singularize(keyTable))# = variables.#keyTable#Service.getBeanById(rc.#keyTable#Bean.get#capitalizeString(keyTable)#_fk());" & crlf;
			}
		}
		controller &= tab & tab & "if(structKeyExists(rc, 'btnSubmit')) {" & crlf;
		controller &= tab & tab & tab & "rc.msg = " & serviceCall & ".update( rc );" & crlf;
		controller &= tab & tab & tab & "rc." & variables.table & "Bean = " & serviceCall & ".getBeanById(rc." & variables.pkField & ");" & crlf;
		controller &= tab & tab & "}" & crlf;
		controller &= tab & "}" & crlf & crlf;

		controller &= tab & "public any function update(required struct rc ) {" & crlf;
		controller &= tab & tab & "rc." & variables.table & "Bean = " & serviceCall & ".getBeanById(rc." & variables.pkField & ");" & crlf;
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
				keyTable = mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3);
				controller &= tab & tab & "rc." & keyTable & " = variables." & keyTable & "Service.getAll();" & crlf;
			}
		}
		controller &= tab & tab & "if(structKeyExists(rc, 'btnSubmit')) {" & crlf;
		controller &= tab & tab & tab & "rc.msg = " & serviceCall & ".update( rc );" & crlf;
		controller &= tab & tab & tab & "rc." & variables.table & "Bean = " & serviceCall & ".getBeanById(rc." & variables.pkField & ");" & crlf;
		controller &= tab & tab & "}" & crlf;
		controller &= tab & "}" & crlf & crlf;

		controller &= tab & "public any function delete(required struct rc ) {" & crlf;
		controller &= tab & tab & "var bean = " & serviceCall & ".getBeanById(rc." & variables.pkField & ");" & crlf;
		controller &= tab & tab & "rc.msg = " & serviceCall & ".delete( bean );" & crlf;
		controller &= tab & tab & "variables.fw.redirect( '" & variables.table & ".default' );" & crlf;
		controller &= tab & "}" & crlf;

		controller &= crlf;
		controller &= tab & "// *********************************  PRIVATE METHODS  *******************************************";
		controller &= crlf;

		controller &= "}";

		return controller;
	}

	// Service Generator
	public string function generateService() {
		dao = variables.table & "DAO";

		var service = "component accessors=true extends='#variables.sitetitle#.common.baseClasses.baseService'{" & crlf & crlf;
		service &= tab & "property " & dao & ";" & crlf & crlf;

		service &= tab & "function init( beanFactory ) {" & crlf;
		service &= tab & tab & "variables.beanFactory = beanFactory;" & crlf;
		service &= tab & tab & "return this;" & crlf;
		service &= tab & "}" & crlf & crlf;

		//delete function
		service &= tab & "public any function delete(required any bean) {" & crlf;
		service &= tab & tab & "return get" & capitalizeString(dao) & "().delete(bean);" & crlf;
		service &= tab & "}" & crlf & crlf;

		//get function
		service &= tab & "public array function get() {" & crlf;
		service &= tab & tab & "return get" & capitalizeString(dao) & "().get(argumentCollection=arguments);" & crlf;
		service &= tab & "}" & crlf & crlf;

		//getNew function
		service &= tab & "public any function getNew() {" & crlf;
		service &= tab & tab & "return variables.beanFactory.getBean('" & variables.table &"');" & crlf;
		service &= tab & "}" & crlf & crlf;

		//save function
		service &= tab & "public any function save(required any bean) {" & crlf;
		service &= tab & tab & "return get" & capitalizeString(dao) & "().save(bean);" & crlf;
		service &= tab & "}" & crlf & crlf;


		service &= "}"; // close component

		return service;
	}

	// DAO Generator
	public string function generateDAO() {
		var dao = "component accessors=true extends='#variables.sitetitle#.common.baseClasses.baseDAO' {" & crlf & crlf;

		//Init
		dao &= tab & "function init(beanFactory, config) {" & crlf;
		dao &= tab & tab & "variables.beanFactory = beanFactory;" & crlf;
		dao &= tab & tab & "variables.config = config;" & crlf;
		dao &= tab & tab & "variables.columnList = '#variables.columnNames#';" & crlf & crlf;

		dao &= tab & tab & "return this;" & crlf;
		dao &= tab & "}" & crlf & crlf;

		// Delete
		dao &= tab & "public any function delete(required any bean) {" & crlf;
		dao &= tab & tab & "try{" & crlf;

		dao &= tab & tab & tab & "var qry = new query();" & crlf;
		dao &= tab & tab & tab & "qry.setDatasource(variables.config.getDatasource());" & crlf & crlf;

		dao &= tab & tab & tab & "var sqlString = 'Delete from ##variables.config.getSchema()##.#variables.table# where #variables.pkField# = :pkValue';" & crlf;
		dao &= tab & tab & tab & "qry.addParam(name='pkValue', value='##arguments.bean.get" & capitalizeString(variables.pkField) & "()##',CFSQLTYPE='CF_SQL_";
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(variables.tableColumns.Is_PrimaryKey[i]){
				switch(variables.tableColumns.type_name[i]) {
					case "bit":
						dao &= "BIT');" & crlf;
						break;
					case "char": case "nchar": case "uniqueidentifier": case "guid":
						dao &= "CHAR');" & crlf;
						break;
					case "decimal": case "money": case "smallmoney":
						dao &= "DECIMAL');" & crlf;
						break;
					case "float":
						dao &= "FLOAT');" & crlf;
						break;
					case "int": case "integer": case "int identity":
						dao &= "INTEGER');" & crlf;
						break;
					case "text": case "ntext":
						dao &= "LONGVARCHAR');" & crlf;
						break;
					case "numeric":
						dao &= "NUMERIC');" & crlf;
						break;
					case "real":
						dao &= "REAL');" & crlf;
						break;
					case "smallint":
						dao &= "SMALLINT');" & crlf;
						break;
					case "date":
						dao &= "DATE');" & crlf;
						break;
					case "time":
						dao &= "TIME');" & crlf;
						break;
					case "datetime": case "smalldatetime":
						dao &= "TIMESTAMP');" & crlf;
						break;
					case "tinyint":
						dao &= "TINYINT');" & crlf;
						break;
					case "varchar": case "nvarchar":
						dao &= "VARCHAR');" & crlf;
						break;
					default:
						dao &= "VARCHAR');" & crlf;
						break;
				}
			}
		}

		dao &= tab & tab & tab & "qry.setSQL(sqlString);" & crlf & crlf;

		dao &= tab & tab & tab & "qry.execute();" & crlf;
		dao &= tab & tab & "} catch (any e) {" & crlf;
		dao &= tab & tab & tab & "bean.setError('Record was not deleted.',e);" & crlf;
		dao &= tab & tab & "}" & crlf;
		dao &= tab & tab & "return bean;" & crlf;
		dao &= tab & "}" & crlf & crlf;

		// Get
		dao &= tab & "public array function get() {" & crlf;
		dao &= tab & tab & "var qry = new query();" & crlf;
		dao &= tab & tab & "var sqlString = 'select ##variables.columnList## from ##variables.config.getSchema()##.#variables.table# where 1=1 ';" & crlf & crlf;

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			dao &= tab & tab & "if(structkeyexists(arguments, '" & variables.tableColumns.column_name[i] & "')){" & crlf;
			dao &= tab & tab & tab & "sqlString &= ' and " & variables.tableColumns.column_name[i] & " = :param" & i & "';" & crlf;
			dao &= tab & tab & tab & "qry.addParam(name='param" & i & "', value='##arguments." & variables.tableColumns.column_name[i] & "##',CFSQLTYPE='CF_SQL_";
			switch(variables.tableColumns.type_name[i]) {
				case "bit":
					dao &= "BIT');" & crlf;
					break;
				case "char": case "nchar": case "uniqueidentifier": case "guid":
					dao &= "CHAR');" & crlf;
					break;
				case "decimal": case "money": case "smallmoney":
					dao &= "DECIMAL');" & crlf;
					break;
				case "float":
					dao &= "FLOAT');" & crlf;
					break;
				case "int": case "integer": case "int identity":
					dao &= "INTEGER');" & crlf;
					break;
				case "text": case "ntext":
					dao &= "LONGVARCHAR');" & crlf;
					break;
				case "numeric":
					dao &= "NUMERIC');" & crlf;
					break;
				case "real":
					dao &= "REAL');" & crlf;
					break;
				case "smallint":
					dao &= "SMALLINT');" & crlf;
					break;
				case "date":
					dao &= "DATE');" & crlf;
					break;
				case "time":
					dao &= "TIME');" & crlf;
					break;
				case "datetime":
					dao &= "TIMESTAMP');" & crlf;
					break;
				case "smalldatetime":
					dao &= "TIMESTAMP');" & crlf;
					break;
				case "tinyint":
					dao &= "TINYINT');" & crlf;
					break;
				case "nvarchar":
					dao &= "VARCHAR');" & crlf;
					break;
				default:
					dao &= "VARCHAR');" & crlf;
					break;
			}

			dao &= tab & tab & "}" & crlf & crlf;
		}

		dao &= tab & tab & "if(structKeyExists(arguments,'customWhere'))" & crlf;
		dao &= tab & tab & tab & "sqlString &= ' AND ' & arguments.customWhere;" & crlf;
		dao &= crlf;

		dao &= tab & tab & "if(structKeyExists(arguments,'orderby'))" & crlf;
		dao &= tab & tab & tab & "sqlString &= ' ' & validateOrderBy(arguments.orderBy);" & crlf;
		dao &= crlf;

		dao &= tab & tab & "qry.setDatasource(variables.config.getDatasource());" & crlf;
		dao &= tab & tab & "qry.setSQL(sqlString);" & crlf & crlf;
		dao &= tab & tab & "try{" & crlf;
		dao &= tab & tab & tab & "return queryToBeanArray(qry.execute().getResult(),'#variables.table#');" & crlf;
		dao &= tab & tab & "} catch(any e){" & crlf;
		dao &= tab & tab & tab & "var bean = variables.beanFactory.getBean('#variables.table#');" & crlf;
		dao &= tab & tab & tab & "bean.setError('Get Failed', e);" & crlf;
		dao &= tab & tab & tab & "return [bean];" & crlf;
		dao &= tab & tab & "}" & crlf;
		dao &= tab & "}" & crlf & crlf;

		// Save
		dao &= tab & "public any function save(required any bean) {" & crlf;

		dao &= tab & tab & "var qry = new query();" & crlf;
		dao &= tab & tab & 'var sqlString = "";' & crlf & crlf;
		dao &= tab & tab & "qry.setDatasource(variables.config.getDatasource());" & crlf & crlf;

		dao &= tab & tab & "if(len(bean.getValue('#variables.pkfield#')) eq 0){" & crlf;
		dao &= tab & tab & tab & "bean.set#capitalizeString(variables.pkfield)#(createUUID());" & crlf;
		dao &= tab & tab & tab & "sqlString = 'Insert Into ##variables.config.getSchema()##.#variables.table#(";

		aList = "";
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			aList &= variables.tableColumns.column_name[i] & ",";
		}
		aList = mid(aList, 1, len(aList)-1);
		dao &= aList;
		dao &= ")'" & crlf;

		dao &= tab & tab & tab & tab & "& ' values(";
		bList = "";
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			bList &= ":" & variables.tableColumns.column_name[i] & ",";
		}
		bList = mid(bList, 1, len(bList)-1);
		dao &= bList;
		dao &= ")';" & crlf;

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			dao &= tab & tab & tab & "qry.addParam(name='" & variables.tableColumns.column_name[i] & "', value='##arguments.bean.get" & capitalizeString(variables.tableColumns.column_name[i]) & "()##',CFSQLTYPE='CF_SQL_";
			switch(variables.tableColumns.type_name[i]) {
				case "bit":
					dao &= "BIT');" & crlf;
					break;
				case "char": case "nchar": case "uniqueidentifier": case "guid":
					dao &= "CHAR');" & crlf;
					break;
				case "decimal": case "money": case "smallmoney":
					dao &= "DECIMAL');" & crlf;
					break;
				case "float":
					dao &= "FLOAT');" & crlf;
					break;
				case "int": case "integer": case "int identity":
					dao &= "INTEGER');" & crlf;
					break;
				case "text": case "ntext":
					dao &= "LONGVARCHAR');" & crlf;
					break;
				case "numeric":
					dao &= "NUMERIC');" & crlf;
					break;
				case "real":
					dao &= "REAL');" & crlf;
					break;
				case "smallint":
					dao &= "SMALLINT');" & crlf;
					break;
				case "date":
					dao &= "DATE');" & crlf;
					break;
				case "time":
					dao &= "TIME');" & crlf;
					break;
				case "datetime": case "smalldatetime":
					dao &= "TIMESTAMP');" & crlf;
					break;
				case "tinyint":
					dao &= "TINYINT');" & crlf;
					break;
				case "varchar": case "nvarchar":
					dao &= "VARCHAR');" & crlf;
					break;
				default:
					dao &= "VARCHAR');" & crlf;
					break;
			}
		}

		dao &= tab & tab & tab & "qry.setSQL(sqlString);" & crlf;

		dao &= tab & tab & "}" & crlf;
		dao &= tab & tab & "else{" & crlf;

		dao &= tab & tab & tab & "sqlString = 'Update ##variables.config.getSchema()##.#variables.table# Set'" & crlf;

		uList = "";
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(variables.tableColumns.is_primarykey[i] eq false) {
				ulist &= tab & tab & tab & tab & "& ' #variables.tableColumns.column_name[i]# = :#variables.tableColumns.column_name[i]##iif(i lt variables.tableColumns.recordCount,de(','),de(''))#'" & crlf;
			}
		}
		ulist = mid(ulist,1,len(ulist)-3);
		dao &= ulist & "'" & crlf;
		dao &= tab & tab & tab & tab & "& ' where #variables.pkField# = :#variables.pkField#';" & crlf;
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(variables.tableColumns.is_primarykey[i] eq false) {
				dao &= tab & tab & tab & "qry.addParam(name='" & variables.tableColumns.column_name[i] & "', value='##arguments.bean.get" & capitalizeString(variables.tableColumns.column_name[i]) & "()##',CFSQLTYPE='CF_SQL_";
				switch(variables.tableColumns.type_name[i]) {
					case "bit":
						dao &= "BIT');" & crlf;
						break;
					case "char": case "nchar": case "uniqueidentifier": case "guid":
						dao &= "CHAR');" & crlf;
						break;
					case "decimal": case "money": case "smallmoney":
						dao &= "DECIMAL');" & crlf;
						break;
					case "float":
						dao &= "FLOAT');" & crlf;
						break;
					case "int": case "integer": case "int identity":
						dao &= "INTEGER');" & crlf;
						break;
					case "text": case "ntext":
						dao &= "LONGVARCHAR');" & crlf;
						break;
					case "numeric":
						dao &= "NUMERIC');" & crlf;
						break;
					case "real":
						dao &= "REAL');" & crlf;
						break;
					case "smallint":
						dao &= "SMALLINT');" & crlf;
						break;
					case "date":
						dao &= "DATE');" & crlf;
						break;
					case "time":
						dao &= "TIME');" & crlf;
						break;
					case "datetime": case "smalldatetime":
						dao &= "TIMESTAMP');" & crlf;
						break;
					case "tinyint":
						dao &= "TINYINT');" & crlf;
						break;
					case "varchar": case "nvarchar":
						dao &= "VARCHAR');" & crlf;
						break;
					default:
						dao &= "VARCHAR');" & crlf;
						break;
				}
			}
		}

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(variables.tableColumns.is_primarykey[i] eq true) {
				dao &= tab & tab & tab & "qry.addParam(name='" & variables.tableColumns.column_name[i] & "', value='##arguments.bean.get" & capitalizeString(variables.tableColumns.column_name[i]) & "()##',CFSQLTYPE='CF_SQL_";
				switch(variables.tableColumns.type_name[i]) {
					case "bit":
						dao &= "BIT');" & crlf;
						break;
					case "char": case "nchar": case "uniqueidentifier": case "guid":
						dao &= "CHAR');" & crlf;
						break;
					case "decimal": case "money": case "smallmoney":
						dao &= "DECIMAL');" & crlf;
						break;
					case "float":
						dao &= "FLOAT');" & crlf;
						break;
					case "int": case "integer": case "int identity":
						dao &= "INTEGER');" & crlf;
						break;
					case "text": case "ntext":
						dao &= "LONGVARCHAR');" & crlf;
						break;
					case "numeric":
						dao &= "NUMERIC');" & crlf;
						break;
					case "real":
						dao &= "REAL');" & crlf;
						break;
					case "smallint":
						dao &= "SMALLINT');" & crlf;
						break;
					case "date":
						dao &= "DATE');" & crlf;
						break;
					case "time":
						dao &= "TIME');" & crlf;
						break;
					case "datetime": case "smalldatetime":
						dao &= "TIMESTAMP');" & crlf;
						break;
					case "tinyint":
						dao &= "TINYINT');" & crlf;
						break;
					case "varchar": case "nvarchar":
						dao &= "VARCHAR');" & crlf;
						break;
					default:
						dao &= "VARCHAR');" & crlf;
						break;
				}
			}
		}

		dao &= tab & tab & tab & "qry.setSQL(sqlString);" & crlf;

		dao &= tab & tab & "}" & crlf & crlf;



		dao &= tab & tab & "try{" & crlf;
		dao &= tab & tab & tab & "qry.execute();" & crlf;
		dao &= tab & tab & "} catch(any e){" & crlf;
		dao &= tab & tab & tab & "bean.setError('Record was not saved.', e);" & crlf;
		dao &= tab & tab & "}" & crlf;
		dao &= tab & tab & "return bean;" & crlf;
		dao &= tab & "}" & crlf; //closes SAVE

		dao &= crlf;
		dao &= "}" & crlf; // closes DAO

		return dao;
	}


	//Data Table Generator
	public string function generateDataTable(){
		var retVar = '<cfsavecontent variable="local.js">' & crlf;
		retVar &= tab & '<script language="JavaScript" type="text/javascript">' & crlf;
		retVar &= tab & tab & '$(document).ready(function() {' & crlf;
		retVar &= tab & tab & tab & 'var #variables.table#Table = $("##' & variables.table & '").dataTable({' & crlf;
		retVar &= tab & tab & tab & tab & '"bJQueryUI": true,' & crlf;
		retVar &= tab & tab & tab & tab & '"sPaginationType": "full_numbers",' & crlf;
		retVar &= tab & tab & tab & tab & '"sRowSelect": "single"' & crlf;
		retVar &= tab & tab & tab & '});' & crlf & crlf;

		retVar &= tab & tab & tab & '$("##' & variables.table & ' tbody").delegate("tr", "click", function() {' & crlf;
		retVar &= tab & tab & tab & tab & 'var iPos = #variables.table#Table.fnGetPosition( this );' & crlf;
		retVar &= tab & tab & tab & tab & 'if(iPos!=null){' & crlf;
		retVar &= tab & tab & tab & tab & tab & 'var aData = #variables.table#Table.fnGetData( iPos );//get data of the clicked row' & crlf;
	    retVar &= tab & tab & tab & tab & tab & 'var iId = aData[0];//get column data of the row' & crlf;
	    retVar &= tab & tab & tab & tab & tab & '<cfoutput>' & crlf;
		retVar &= tab & tab & tab & tab & tab & tab & '<cfset redirectUrl = #apos##quot##apos# & ##buildURL("#variables.table#.viewEdit")## & #apos#&#variables.pkField#=#quot# + iId#apos#>' & crlf;
		retVar &= tab & tab & tab & tab & tab & tab & 'document.location.href = ##redirectUrl##;' & crlf;
		retVar &= tab & tab & tab & tab & tab & '</cfoutput>' & crlf;
		retVar &= tab & tab & tab & tab & '}' & crlf;
		retVar &= tab & tab & tab & '});' & crlf & crlf;

		retVar &= tab & tab & '});' & crlf;
		retVar &= tab & '</script>' & crlf;
		retVar &= '</cfsavecontent>' & crlf & crlf;

		retVar &= '<cfhtmlhead text="##local.js##">' & crlf & crlf;

		retVar &= '<div class="header">' & crlf;
		retVar &= tab & '<h1><cfoutput>##application.sitetitle##</cfoutput></h1>' & crlf;
		retVar &= tab & '<h2>#capitalizeString(variables.table)#</h2>' & crlf;
		retVar &= '</div>' & crlf & crlf;

		retVar &= '<div class="pure-g">' & crlf;
		retVar &= tab & '<div class="pure-u-1-1">' & crlf & crlf;

		retVar &= tab & tab & '<cfif structkeyexists(rc, "msg")>' & crlf;
		retVar &= tab & tab & tab & '<cfif rc.msg.type eq "success">' & crlf;
		retVar &= tab & tab & tab & tab & '<div class="ui-state-highlight ui-corner-all" style="margin-top: 20px; padding: 0 .7em;">' & crlf;
		retVar &= tab & tab & tab & tab &  tab & '<cfoutput>##rc.msg.text##</cfoutput>' & crlf;
		retVar &= tab & tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & tab & '<cfelse>' & crlf;
		retVar &= tab & tab & tab & tab & '<div class="ui-state-error ui-corner-all" style="padding: 0 .7em;">' & crlf;
		retVar &= tab & tab & tab & tab & tab & '<cfoutput>##rc.msg.text##</cfoutput>' & crlf;
		retVar &= tab & tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & tab & '</cfif>' & crlf;
		retVar &= tab & tab & '</cfif>' & crlf & crlf;

		retVar &= tab & tab & '<a href="<cfoutput>##buildURL("#variables.table#.create")##</cfoutput>"><span class="fa fa-plus-circle"></span> Add A #nounForms.singularize(capitalizeString(variables.table))#</a>' & crlf;
		retVar &= tab & tab & '<br><br>' & crlf;
		retVar &= tab & tab & '<table id="#variables.table#" class="display hover">' & crlf;
		retVar &= tab & tab & tab & '<thead>' & crlf;
		retVar &= tab & tab & tab & tab & '<tr align="left">' & crlf;

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(variables.tableColumns.is_primarykey[i] eq true){
				retVar &= tab & tab & tab & tab & tab & '<th class="hide_column">' & variables.tableColumns.column_name[i] & '</th>' & crlf;
			} else {
				if(variables.tableColumns.column_size[i] lte 250) {
					retVar &= tab & tab & tab & tab & tab & '<th>' & decamelizeString(variables.tableColumns.column_name[i]) & '</th>' & crlf;
				}
			}
		}
		retVar &= tab & tab & tab & tab & '</tr>' & crlf;
		retVar &= tab & tab & tab & '</thead>' & crlf;
		retVar &= tab & tab & tab & '<tbody>' & crlf;
		retVar &= tab & tab & tab & tab & '<cfoutput query="rc.#variables.table#">' & crlf;
		retVar &= tab & tab & tab & tab & tab & '<tr>' & crlf;

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(variables.tableColumns.is_primarykey[i] eq true){
				retVar &= tab & tab & tab & tab & tab & tab & '<td class="hide_column">##' & variables.tableColumns.column_name[i] & '##</td>' & crlf;
			} else {
				if(variables.tableColumns.column_size[i] lte 250) {
					retVar &= tab & tab & tab & tab & tab & tab & '<td valign="top">';
					if(variables.tableColumns.type_name[i] eq "money") {
						retVar &= '##dollarformat(#variables.tableColumns.column_name[i]#)##';
					} else if(variables.tableColumns.type_name[i] eq "bit") {
						retVar &= '<cfif #variables.tableColumns.column_name[i]# eq 1>True<cfelse>False</cfif>';
					} else {
						retVar &= '##' & variables.tableColumns.column_name[i] & '##';
					}
					retVar &= '</td>' & crlf;
				}
			}
		}

		retVar &= tab & tab & tab & tab & tab & '</tr>' & crlf;
		retVar &= tab & tab & tab & tab & '</cfoutput>' & crlf;
		retVar &= tab & tab & tab & '</tbody>' & crlf;
		retVar &= tab & tab & '</table>' & crlf;

		retVar &= tab & '</div>' & crlf;
		retVar &= '</div>' & crlf & crlf;

		return retVar;
	}

	//Create Form Generator
	public string function generateCreateForm(){
		var retVar = '<cfsavecontent variable="local.js">' & crlf;
		retVar &= tab & '<script language="JavaScript" type="text/javascript">' & crlf;
		retVar &= tab & tab & '$(document).ready(function() {' & crlf;
		retVar &= tab & tab & tab & '$(".datepicker").datepicker();' & crlf;
		retVar &= tab & tab & tab & '$(".spinner").spinner();' & crlf;
		retVar &= tab & tab & '});' & crlf;
		retVar &= tab & '</script>' & crlf;
		retVar &= '</cfsavecontent>' & crlf & crlf;

		retVar &= '<cfhtmlhead text="##local.js##">' & crlf & crlf;

		retVar &= '<div class="header">' & crlf;
		retVar &= tab & '<h1><cfoutput>##application.sitetitle##</cfoutput></h1>' & crlf;
		retVar &= tab & '<h2>Create A #nounForms.singularize(capitalizeString(variables.table))#</h2>' & crlf;
		retVar &= '</div>' & crlf & crlf;

		retVar &= '<div class="pure-g">' & crlf;
		retVar &= tab & '<div class="pure-u-1-1">' & crlf & crlf;

		retVar &= tab & tab & '<cfif structkeyexists(rc, "msg")>' & crlf;
		retVar &= tab & tab & tab & '<cfif rc.msg.type eq "success">' & crlf;
		retVar &= tab & tab & tab & tab & '<div class="ui-state-highlight ui-corner-all" style="margin-top: 20px; padding: 0 .7em;">' & crlf;
		retVar &= tab & tab & tab & tab &  tab & '<cfoutput>##rc.msg.text##</cfoutput>' & crlf;
		retVar &= tab & tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & tab & '<cfelse>' & crlf;
		retVar &= tab & tab & tab & tab & '<div class="ui-state-error ui-corner-all" style="padding: 0 .7em;">' & crlf;
		retVar &= tab & tab & tab & tab & tab & '<cfoutput>##rc.msg.text##</cfoutput>' & crlf;
		retVar &= tab & tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & tab & '</cfif>' & crlf;
		retVar &= tab & tab & '</cfif>' & crlf & crlf;

		retVar &= tab & tab & '<p style="font-size:9pt; font-weight:bold; margin-top:10px;">' & crlf;
		retVar &= tab & tab & tab & '<a href="<cfoutput>##buildURL("#variables.table#.default")##</cfoutput>" style="text-decoration:none">' & crlf;
		retVar &= tab & tab & tab & tab & '<span class="fa fa-arrow-left"></span> Return to #capitalizeString(variables.table)#' & crlf;
		retVar &= tab & tab & tab & '</a>' & crlf;
		retVar &= tab & tab & '</p>' & crlf & crlf;

		retVar &= tab & tab & '<form action="<cfoutput>##buildURL("#variables.table#.create")##</cfoutput>" method="post" id="#variables.table#Form" class="pure-form pure-form-aligned">' & crlf;

		for(i=1;i<=variables.tableColumns.recordCount;i++) {

			if(variables.tableColumns.is_primarykey[i] neq "yes") {
				retVar &= tab & tab & tab & tab & '<div class="pure-control-group">' & crlf;

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
					retVar &= tab & tab & tab & tab & tab &'<label>#decamelizeString(nounForms.singularize(capitalizeString(keyTable)))#</label>' & crlf;
					retVar &= tab & tab & tab & tab & tab &'<select name="#variables.tableColumns.column_name[i]#">' & crlf;
					retVar &= tab & tab & tab & tab & tab & tab & '<cfoutput query="rc.#pluralTable#">' & crlf;
					retVar &= tab & tab & tab & tab & tab & tab & tab & '<option value="###pkKeyTable###">###keyTableTitle###</option>' & crlf;
					retVar &= tab & tab & tab & tab & tab & tab & '</cfoutput>' & crlf;
					retVar &= tab & tab & tab & tab & tab & '</select>' & crlf;
				} else {
					retVar &= tab & tab & tab & tab & tab &'<label>#decamelizeString(nounForms.singularize(capitalizeString(variables.tableColumns.column_name[i])))#</label>' & crlf;
					switch(variables.tableColumns.type_name[i]) {
						case "bit":
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="radio" value="1"/> True' & crlf;
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="radio" value="0"/> False' & crlf;
						break;

						case "char": case "nchar": case "varchar": case "varchar(max)": case "nvarchar": case "text": case "ntext":
							if(variables.tableColumns.column_size[i] lte 250) {
								retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" maxlength="50" />' & crlf;
							} else {
								retVar &= tab & tab & tab & tab & tab &'<textarea name="#variables.tableColumns.column_name[i]#" cols="48" rows="4"></ textarea>' & crlf;
							}
						break;

						case "date": case "datetime": case "smalldatetime":
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" class="datepicker" />' & crlf;
						break;

						case "int": case "integer": case "smallint": case "tinyint":
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" class="spinner" />' & crlf;
						break;

						case "decimal": case "money": case "smallmoney": case "float": case "numeric": case "real":
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="20" />' & crlf;
						break;

						default:
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" maxlength="50" />' & crlf;
						break;
					}
				}
				retVar &= tab & tab & tab & tab & '</div>' & crlf & crlf;

			}

		}

		retVar &= tab & tab & tab & tab & '<div class="pure-control-group">' & crlf;
		retVar &= tab & tab & tab & tab & tab &'<label>&nbsp;</label>' & crlf;
		retVar &= tab & tab & tab & tab & tab &'<input name="btnSubmit" type="submit" value="Create This #nounForms.singularize(capitalizeString(variables.table))#" SubmitOnce="true" class="pure-button pure-button-primary" />' & crlf;
		retVar &= tab & tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & '</form>' & crlf;
		retVar &= tab & '</div>' & crlf;
		retVar &= '</div>' & crlf & crlf;

		retVar &= '<script type="text/javascript">' & crlf;
		retVar &= tab & '$( "##' & variables.table & 'Form" ).validate({' & crlf;
		retVar &= tab & tab & 'rules: {' & crlf;

		for(i=1;i<=variables.tableColumns.recordCount;i++) {

			if(variables.tableColumns.is_primarykey[i] neq "yes") {
				retVar &= tab & tab & tab & '#variables.tableColumns.column_name[i]#{ ';

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

				retVar &= ' },' & crlf;

			}

		}

		retVar = mid(retVar,1,len(retVar)-3);
		retVar &= '}' & crlf;
		retVar &= tab & tab & '}' & crlf;
		retVar &= tab & '});' & crlf;
		retVar &= '</script>';

		return retVar;
	}


	//Update Form Generator
	public string function generateUpdateForm(){
		var retVar = '<cfsavecontent variable="local.js">' & crlf;
		retVar &= tab & '<script language="JavaScript" type="text/javascript">' & crlf;
		retVar &= tab & tab & '$(document).ready(function() {' & crlf;
		retVar &= tab & tab & tab & '$(".datepicker").datepicker();' & crlf;
		retVar &= tab & tab & tab & '$(".spinner").spinner();' & crlf;
		retVar &= tab & tab & '});' & crlf;
		retVar &= tab & '</script>' & crlf;
		retVar &= '</cfsavecontent>' & crlf & crlf;

		retVar &= '<cfhtmlhead text="##local.js##">' & crlf & crlf;

		retVar &= '<div class="header">' & crlf;
		retVar &= tab & '<h1><cfoutput>##application.sitetitle##</cfoutput></h1>' & crlf;
		retVar &= tab & '<h2><cfoutput>';
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('Name', variables.tableColumns.column_name[i]) neq 0) {
			  retVar &= '##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## ';
			 }
		}
		retVar &= '</cfoutput></h2>' & crlf;
		retVar &= '</div>' & crlf & crlf;

		retVar &= '<div class="pure-g">' & crlf;
		retVar &= tab & '<div class="pure-u-1-1">' & crlf & crlf;

		retVar &= tab & tab & '<cfif structkeyexists(rc, "msg")>' & crlf;
		retVar &= tab & tab & tab & '<cfif rc.msg.type eq "success">' & crlf;
		retVar &= tab & tab & tab & tab & '<div class="ui-state-highlight ui-corner-all" style="margin-top: 20px; padding: 0 .7em;">' & crlf;
		retVar &= tab & tab & tab & tab &  tab & '<cfoutput>##rc.msg.text##</cfoutput>' & crlf;
		retVar &= tab & tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & tab & '<cfelse>' & crlf;
		retVar &= tab & tab & tab & tab & '<div class="ui-state-error ui-corner-all" style="padding: 0 .7em;">' & crlf;
		retVar &= tab & tab & tab & tab & tab & '<cfoutput>##rc.msg.text##</cfoutput>' & crlf;
		retVar &= tab & tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & tab & '</cfif>' & crlf;
		retVar &= tab & tab & '</cfif>' & crlf & crlf;

		retVar &= tab & tab & '<p style="font-size:9pt; font-weight:bold; margin-top:10px;">' & crlf;
		retVar &= tab & tab & tab & '<a href="<cfoutput>##buildURL("#variables.table#.default")##</cfoutput>" style="text-decoration:none">' & crlf;
		retVar &= tab & tab & tab & tab & '<span class="fa fa-arrow-left"></span> Return to #capitalizeString(variables.table)#' & crlf;
		retVar &= tab & tab & tab & '</a>' & crlf;
		retVar &= tab & tab & '</p>' & crlf & crlf;

		retVar &= tab & tab & '<cfoutput>' & crlf;
		retVar &= tab & tab & '<form action="##buildURL("#variables.table#.update")##" method="post" id="#variables.table#Form" class="pure-form pure-form-aligned">' & crlf;
		retVar &= tab & tab & tab & '<fieldset>' & crlf;
		retVar &= tab & tab & tab & tab & '<legend>Update ##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##</legend>' & crlf & crlf;

		for(i=1;i<=variables.tableColumns.recordCount;i++) {

			if(variables.tableColumns.is_primarykey[i] neq "yes") {

				retVar &= tab & tab & tab & tab & '<div class="pure-control-group">' & crlf;

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
					retVar &= tab & tab & tab & tab & tab &'<label>#decamelizeString(nounForms.singularize(capitalizeString(keyTable)))#</label>' & crlf;
					retVar &= tab & tab & tab & tab & tab &'<select name="#variables.tableColumns.column_name[i]#">' & crlf;
					retVar &= tab & tab & tab & tab & tab & tab & '<cfoutput query="rc.#pluralTable#">' & crlf;
					retVar &= tab & tab & tab & tab & tab & tab & tab & '<option value="###pkKeyTable###"<cfif ###pkKeyTable### eq ##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##>selected="selected"</cfif>>###keyTableTitle###</option>' & crlf;
					retVar &= tab & tab & tab & tab & tab & tab & '</cfoutput>' & crlf;
					retVar &= tab & tab & tab & tab & tab & '</select>' & crlf;
				} else {
					retVar &= tab & tab & tab & tab & tab &'<label>#decamelizeString(nounForms.singularize(capitalizeString(variables.tableColumns.column_name[i])))#</label>' & crlf;
					switch(variables.tableColumns.type_name[i]) {
						case "bit":
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="radio" value="1" <cfif ##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## eq 1>checked="checked"</cfif>/> True' & crlf;
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="radio" value="0" <cfif ##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## eq 0>checked="checked"</cfif>/> False' & crlf;
						break;

						case "char": case "nchar": case "varchar": case "varchar(max)": case "nvarchar": case "text": case "ntext":
							if(variables.tableColumns.column_size[i] lte 250) {
								retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" maxlength="50" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & crlf;
							} else {
								retVar &= tab & tab & tab & tab & tab &'<textarea name="#variables.tableColumns.column_name[i]#" cols="48" rows="4">##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##"</ textarea>' & crlf;
							}
						break;

						case "date": case "datetime": case "smalldatetime":
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" class="datepicker" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & crlf;
						break;

						case "int": case "integer": case "smallint": case "tinyint":
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" class="spinner" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & crlf;
						break;

						case "decimal": case "money": case "smallmoney": case "float": case "numeric": case "real":
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="20" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & crlf;
						break;

						default:
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" maxlength="50" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & crlf;
						break;
					}
				}
				retVar &= tab & tab & tab & tab & '</div>' & crlf & crlf;

			}

		}

		retVar &= tab & tab & tab & tab & '<div class="pure-control-group">' & crlf;
		retVar &= tab & tab & tab & tab & tab &'<label>&nbsp;</label>' & crlf;
		retVar &= tab & tab & tab & tab & tab &'<input name="#variables.pkField#" type="hidden" value="##rc.#variables.table#Bean.get#capitalizeString(variables.pkField)#()##" />' & crlf;
		retVar &= tab & tab & tab & tab & tab &'<input name="btnSubmit" type="submit" value="Submit" SubmitOnce="true" class="pure-button pure-button-primary" />' & crlf;
		retVar &= tab & tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & tab & '</fieldset>' & crlf;
		retVar &= tab & tab & '</form>' & crlf;
		retVar &= tab & tab & '</cfoutput>' & crlf;
		retVar &= tab & '</div>' & crlf;
		retVar &= '</div>' & crlf & crlf;

		retVar &= '<script type="text/javascript">' & crlf;
		retVar &= tab & '$( "##' & variables.table & 'Form" ).validate({' & crlf;
		retVar &= tab & tab & 'rules: {' & crlf;

		for(i=1;i<=variables.tableColumns.recordCount;i++) {

			if(variables.tableColumns.is_primarykey[i] neq "yes") {
				retVar &= tab & tab & tab & '#variables.tableColumns.column_name[i]#{ ';

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

				retVar &= ' },' & crlf;

			}

		}

		retVar = mid(retVar,1,len(retVar)-3);
		retVar &= '}' & crlf;
		retVar &= tab & tab & '}' & crlf;
		retVar &= tab & '});' & crlf;
		retVar &= '</script>';

		return retVar;
	}

	//View Generator
	public string function generateView() {
		var retVar = '<div class="header">' & crlf;
		retVar &= tab & '<h1><cfoutput>##application.sitetitle##</cfoutput></h1>' & crlf;
		retVar &= tab & '<h2><cfoutput>';
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('Name', variables.tableColumns.column_name[i]) neq 0) {
			  retVar &= '##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## ';
			 }
		}
		retVar &= '</cfoutput></h2>' & crlf;
		retVar &= '</div>' & crlf & crlf;

		retVar &= '<div class="pure-g">' & crlf;
		retVar &= tab & '<div class="pure-u-1-1">' & crlf & crlf;

		retVar &= tab & tab & '<cfif structkeyexists(rc, "msg")>' & crlf;
		retVar &= tab & tab & tab & '<cfif rc.msg.type eq "success">' & crlf;
		retVar &= tab & tab & tab & tab & '<div class="ui-state-highlight ui-corner-all" style="margin-top: 20px; padding: 0 .7em;">' & crlf;
		retVar &= tab & tab & tab & tab &  tab & '<cfoutput>##rc.msg.text##</cfoutput>' & crlf;
		retVar &= tab & tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & tab & '<cfelse>' & crlf;
		retVar &= tab & tab & tab & tab & '<div class="ui-state-error ui-corner-all" style="padding: 0 .7em;">' & crlf;
		retVar &= tab & tab & tab & tab & tab & '<cfoutput>##rc.msg.text##</cfoutput>' & crlf;
		retVar &= tab & tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & tab & '</cfif>' & crlf;
		retVar &= tab & tab & '</cfif>' & crlf & crlf;

		retVar &= tab & tab & '<cfoutput>' & crlf;

		retVar &= tab & tab & tab & '<p style="font-size:9pt; font-weight:bold; margin-top:10px;">' & crlf;
		retVar &= tab & tab & tab & tab & '<a href="##buildURL(#variables.apos##variables.table#.default#variables.apos#)##" style="text-decoration:none">' & crlf;
		retVar &= tab & tab & tab & tab & tab & '<span class="fa fa-arrow-left"></span> Return to #variables.table#' & crlf;
		retVar &= tab & tab & tab & tab & '</a> | ' & crlf;
		retVar &= tab & tab & tab & tab & '<a href="##buildURL(#variables.apos##variables.table#.update?#variables.pkField#=##rc.#variables.table#Bean.get#capitalizeString(variables.pkField)#()###variables.apos#)##" style="text-decoration: none;">' & crlf;
		retVar &= tab & tab & tab & tab & tab & '<span class="fa fa-pencil-square-o"></span> Update This #nounForms.singularize(capitalizeString(variables.table))#' & crlf;
		retVar &= tab & tab & tab & tab & '</a> |' & crlf;
		retVar &= tab & tab & tab & tab & '<a href="##buildURL(#variables.apos##variables.table#.delete?#variables.pkField#=##rc.#variables.table#Bean.get#capitalizeString(variables.pkField)#()###variables.apos#)##" onclick="javascript:return confirm(#variables.apos#Are you sure you want to delete ';
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('Name', variables.tableColumns.column_name[i]) neq 0) {
			  retVar &= '##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## ';
			 }
		}
		retVar &= '#variables.apos#)" style="text-decoration: none;">' & crlf;
		retVar &= tab & tab & tab & tab & tab & '<span class="fa fa-minus-circle"></span> Delete This #nounForms.singularize(capitalizeString(variables.table))#' & crlf;
		retVar &= tab & tab & tab & tab & '</a>' & crlf;
		retVar &= tab & tab & tab & '</p>' & crlf & crlf;

		retVar &= tab & tab & tab & '<div class="pure-g">' & crlf;
		retVar &= tab & tab & tab & tab & '<table class="pure-table pure-u-1-1">' & crlf;
		retVar &= tab & tab & tab & tab & tab & '<tbody>' & crlf;

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
		if(variables.tableColumns.is_primarykey[i] neq "yes") {

		if(i mod 2 eq 1){
		retVar &= tab & tab & tab & tab & tab & tab & '<tr class="pure-table-odd">' & crlf;
		} else {
		retVar &= tab & tab & tab & tab & tab & tab & '<tr>' & crlf;
		}
		if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
			fieldLabel = mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3);
		} else {
			fieldLabel = variables.tableColumns.column_name[i];
		}
		retVar &= tab & tab & tab & tab & tab & tab & tab & '<td><strong>#decamelizeString(nounForms.singularize(capitalizeString(fieldLabel)))#</strong></td>' & crlf;
		retVar &= tab & tab & tab & tab & tab & tab & tab & '<td>';
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
		retVar &= '</td>' & crlf;
		retVar &= tab & tab & tab & tab & tab & tab & '</tr>' & crlf;

			}
		}
		retVar &= tab & tab & tab & tab & tab & '</tbody>' & crlf;
		retVar &= tab & tab & tab & tab & '</table>' & crlf;
		retVar &= tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & '</cfoutput>' & crlf;
		retVar &= tab & '</div>' & crlf;
		retVar &= '</div>' & crlf;

		return retVar;
	}


	//ViewEdit Generator
	public string function generateViewEdit() {
		var retVar = '<cfsavecontent variable="local.js">' & crlf;
		retVar &= tab & '<script language="JavaScript" type="text/javascript">' & crlf;
		retVar &= tab & tab & '$(document).ready(function() {' & crlf;
		retVar &= tab & tab & tab & '$(".datepicker").datepicker();' & crlf;
		retVar &= tab & tab & tab & '$(".spinner").spinner();' & crlf;
		retVar &= tab & tab & '});' & crlf;
		retVar &= tab & '</script>' & crlf;
		retVar &= '</cfsavecontent>' & crlf & crlf;

		retVar &= '<cfhtmlhead text="##local.js##">' & crlf & crlf;

		retVar &= '<div class="header">' & crlf;
		retVar &= tab & '<h1><cfoutput>##application.sitetitle##</cfoutput></h1>' & crlf;
		retVar &= tab & '<h2><cfoutput>';
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('Name', variables.tableColumns.column_name[i]) neq 0) {
			  retVar &= '##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## ';
			 }
		}
		retVar &= '</cfoutput></h2>' & crlf;
		retVar &= '</div>' & crlf & crlf;

		retVar &= '<div class="pure-g">' & crlf;
		retVar &= tab & '<div class="pure-u-1-1">' & crlf & crlf;

		retVar &= tab & tab & '<cfif structkeyexists(rc, "msg")>' & crlf;
		retVar &= tab & tab & tab & '<cfif rc.msg.type eq "success">' & crlf;
		retVar &= tab & tab & tab & tab & '<div class="ui-state-highlight ui-corner-all" style="margin-top: 20px; padding: 0 .7em;">' & crlf;
		retVar &= tab & tab & tab & tab &  tab & '<cfoutput>##rc.msg.text##</cfoutput>' & crlf;
		retVar &= tab & tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & tab & '<cfelse>' & crlf;
		retVar &= tab & tab & tab & tab & '<div class="ui-state-error ui-corner-all" style="padding: 0 .7em;">' & crlf;
		retVar &= tab & tab & tab & tab & tab & '<cfoutput>##rc.msg.text##</cfoutput>' & crlf;
		retVar &= tab & tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & tab & '</cfif>' & crlf;
		retVar &= tab & tab & '</cfif>' & crlf & crlf;

		retVar &= tab & tab & '<cfoutput>' & crlf;

		retVar &= tab & tab & tab & '<p style="font-size:9pt; font-weight:bold; margin-top:10px;">' & crlf;
		retVar &= tab & tab & tab & tab & '<a href="##buildURL(#variables.apos##variables.table#.default#variables.apos#)##" style="text-decoration:none">' & crlf;
		retVar &= tab & tab & tab & tab & tab & '<span class="fa fa-arrow-left"></span> Return to #variables.table#' & crlf;
		retVar &= tab & tab & tab & tab & '</a> | ' & crlf;
		retVar &= tab & tab & tab & tab & '<a href="##buildURL(#variables.apos##variables.table#.delete?#variables.pkField#=##rc.#variables.table#Bean.get#capitalizeString(variables.pkField)#()###variables.apos#)##" onclick="javascript:return confirm(#variables.apos#Are you sure you want to delete ';
		for(i=1;i<=variables.tableColumns.recordCount;i++) {
			if(Find('Name', variables.tableColumns.column_name[i]) neq 0) {
			  retVar &= '##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## ';
			 }
		}
		retVar &= '#variables.apos#)" style="text-decoration: none;">' & crlf;
		retVar &= tab & tab & tab & tab & tab & '<span class="fa fa-minus-circle"></span> Delete This #nounForms.singularize(capitalizeString(variables.table))#' & crlf;
		retVar &= tab & tab & tab & tab & '</a>' & crlf;
		retVar &= tab & tab & tab & '</p>' & crlf & crlf;

		retVar &= tab & tab & tab & '<div id="viewInfo" class="pure-g">' & crlf;
		retVar &= tab & tab & tab & tab & '<button id="showUpdate" class="pure-u-1-1 pure-button pure-button-primary">Update This #nounForms.singularize(capitalizeString(variables.table))#</button>' & crlf;
		retVar &= tab & tab & tab & tab & '<br><br>' & crlf;
		retVar &= tab & tab & tab & tab & '<table class="pure-table pure-u-1-1">' & crlf;
		retVar &= tab & tab & tab & tab & tab & '<tbody>' & crlf;

		for(i=1;i<=variables.tableColumns.recordCount;i++) {
		if(variables.tableColumns.is_primarykey[i] neq "yes") {

		if(i mod 2 eq 1){
		retVar &= tab & tab & tab & tab & tab & tab & '<tr class="pure-table-odd">' & crlf;
		} else {
		retVar &= tab & tab & tab & tab & tab & tab & '<tr>' & crlf;
		}
		if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
			fieldLabel = mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3);
		} else {
			fieldLabel = variables.tableColumns.column_name[i];
		}
		retVar &= tab & tab & tab & tab & tab & tab & tab & '<td><strong>#decamelizeString(nounForms.singularize(capitalizeString(fieldLabel)))#</strong></td>' & crlf;
		retVar &= tab & tab & tab & tab & tab & tab & tab & '<td>';
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
		retVar &= '</td>' & crlf;
		retVar &= tab & tab & tab & tab & tab & tab & '</tr>' & crlf;

			}
		}
		retVar &= tab & tab & tab & tab & tab & '</tbody>' & crlf;
		retVar &= tab & tab & tab & tab & '</table>' & crlf;
		retVar &= tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & tab & '<div id="updateInfo">' & crlf;
		retVar &= tab & tab & tab & tab & '<button id="showView" class="pure-u-1-1 pure-button pure-button-primary">Return To View This #nounForms.singularize(capitalizeString(variables.table))#</button>' & crlf;
		retVar &= tab & tab & tab & tab & '<br><br>' & crlf;
		retVar &= tab & tab & '<cfoutput>' & crlf;
		retVar &= tab & tab & '<form action="##buildURL("#variables.table#.viewedit")##" method="post" id="#variables.table#Form" class="pure-form pure-form-aligned">' & crlf;
		retVar &= tab & tab & tab & '<fieldset>' & crlf;
		retVar &= tab & tab & tab & tab & '<legend>Update #nounForms.singularize(capitalizeString(variables.table))#</legend>' & crlf & crlf;

		for(i=1;i<=variables.tableColumns.recordCount;i++) {

			if(variables.tableColumns.is_primarykey[i] neq "yes") {

				retVar &= tab & tab & tab & tab & '<div class="pure-control-group">' & crlf;
				if(Find('_fk',variables.tableColumns.column_name[i]) neq 0) {
					fieldLabel = mid(variables.tableColumns.column_name[i],1,len(variables.tableColumns.column_name[i])-3);
				} else {
					fieldLabel = variables.tableColumns.column_name[i];
				}
				retVar &= tab & tab & tab & tab & tab &'<label>#decamelizeString(nounForms.singularize(capitalizeString(fieldLabel)))#</label>' & crlf;
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
					retVar &= tab & tab & tab & tab & tab &'<label>#decamelizeString(nounForms.singularize(capitalizeString(keyTable)))#</label>' & crlf;
					retVar &= tab & tab & tab & tab & tab &'<select name="#variables.tableColumns.column_name[i]#">' & crlf;
					retVar &= tab & tab & tab & tab & tab & tab & '<cfoutput query="rc.#pluralTable#">' & crlf;
					retVar &= tab & tab & tab & tab & tab & tab & tab & '<option value="###pkKeyTable###"<cfif ###pkKeyTable### eq ##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##>selected="selected"</cfif>>###keyTableTitle###</option>' & crlf;
					retVar &= tab & tab & tab & tab & tab & tab & '</cfoutput>' & crlf;
					retVar &= tab & tab & tab & tab & tab & '</select>' & crlf;
				} else {
					switch(variables.tableColumns.type_name[i]) {
						case "bit":
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="radio" value="1" <cfif ##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## eq 1>checked="checked"</cfif>/> True' & crlf;
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="radio" value="0" <cfif ##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()## eq 0>checked="checked"</cfif>/> False' & crlf;
						break;

						case "char": case "nchar": case "varchar": case "varchar(max)": case "nvarchar": case "text": case "ntext":
							if(variables.tableColumns.column_size[i] lte 250) {
								retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" maxlength="50" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & crlf;
							} else {
								retVar &= tab & tab & tab & tab & tab &'<textarea name="#variables.tableColumns.column_name[i]#" cols="48" rows="4">##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##"</ textarea>' & crlf;
							}
						break;

						case "date": case "datetime": case "smalldatetime":
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" class="datepicker" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & crlf;
						break;

						case "int": case "integer": case "smallint": case "tinyint":
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" class="spinner" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & crlf;
						break;

						case "decimal": case "money": case "smallmoney": case "float": case "numeric": case "real":
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="20" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & crlf;
						break;

						default:
						retVar &= tab & tab & tab & tab & tab &'<input name="#variables.tableColumns.column_name[i]#" type="text" size="50" maxlength="50" value="##rc.#variables.table#Bean.get#capitalizeString(variables.tableColumns.column_name[i])#()##" />' & crlf;
						break;

					}

					retVar &= tab & tab & tab & tab & '</div>' & crlf & crlf;
					}
				}
		}

		retVar &= tab & tab & tab & tab & '<div class="pure-control-group">' & crlf;
		retVar &= tab & tab & tab & tab & tab &'<label>&nbsp;</label>' & crlf;
		retVar &= tab & tab & tab & tab & tab &'<input name="#variables.pkField#" type="hidden" value="##rc.#variables.table#Bean.get#capitalizeString(variables.pkField)#()##" />' & crlf;
		retVar &= tab & tab & tab & tab & tab &'<input name="btnSubmit" type="submit" value="Update This #nounForms.singularize(capitalizeString(variables.table))#" SubmitOnce="true" class="pure-button pure-button-primary" />' & crlf;
		retVar &= tab & tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & tab & '</fieldset>' & crlf;
		retVar &= tab & tab & '</form>' & crlf;
		retVar &= tab & tab & '</cfoutput>' & crlf;

		retVar &= tab & tab & tab & '</div>' & crlf;
		retVar &= tab & tab & '</cfoutput>' & crlf;
		retVar &= tab & '</div>' & crlf;
		retVar &= '</div>' & crlf;

		retVar &= '<script type="text/javascript">' & crlf;
		retVar &= tab & '$(document).ready(function() {	' & crlf;
		retVar &= tab & tab & '$("##updateInfo").hide();' & crlf;

		retVar &= tab & tab & '$("##showUpdate").click(function(){' & crlf;
		retVar &= tab & tab & tab & '$("##updateInfo").show();' & crlf;
		retVar &= tab & tab & tab & '$("##viewInfo").hide();' & crlf;
		retVar &= tab & tab & '});' & crlf;

		retVar &= tab & tab & '$("##showView").click(function(){' & crlf;
		retVar &= tab & tab & tab & '$("##updateInfo").hide();' & crlf;
		retVar &= tab & tab & tab & '$("##viewInfo").show();' & crlf;
		retVar &= tab & tab & '});' & crlf;

		retVar &= tab & '});' & crlf;
		retVar &= '</script>';

		return retVar;
	}
}
