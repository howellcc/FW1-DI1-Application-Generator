component accessors=true {

	variables.DAO = '';
	variables.entityName = '';

	function init( beanFactory, entityName) {
		variables.beanFactory = beanFactory;
		variables.entityName = entityName;
		return this;
	}

	public void function setDAO(DAO){
		variables.DAO = arguments.DAO;
	}

	//Deletes the record associated with a given bean.
	public any function delete(required any bean) {
		return variables.DAO.delete(bean);
	}

	//Returns a query based on the arguments passed in.
	public query function get() {
		return variables.DAO.get(argumentCollection=arguments);
	}

	//Returns a single bean based on the ID passed in.
	public any function getBean() {
		if(!structKeyExists(arguments, variables.entityName & "ID"))
			throw(message="please provide #variables.entityName#ID", type="interface");
		var qry = variables.DAO.get(argumentCollection=arguments);
		var bean = getNew();
		if(qry.recordCount){
			bean.set(qry);
			bean.setValue("isNew", 0);
		} else{
			bean.setValue("isNew", 1);
		}
		return bean;
	}

	//Returns an iterator populated with the query from the arguments passed in. It passes the arguments along
	//to the get() function and populates the iterator with the results.
	public any function getIterator(){
		return variables.beanFactory.getBean("beanIterator")
										.init(variables.beanFactory)
										.setQuery(get(argumentCollection=arguments))
										.setEntityName(variables.entityName);
	}

	//Gets an empty bean of the appropriate type
	public any function getNew() {
		return variables.beanFactory.getBean(variables.entityName);
	}

	//Saves the data from the provided bean.
	public any function save(required any bean) {
		return variables.DAO.save(bean);
	}

}
