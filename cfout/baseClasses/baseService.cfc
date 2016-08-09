component accessors=true {

	variables.DAO = '';

	function init( beanFactory, entityName) {
		variables.beanFactory = beanFactory;
		return this;
	}

	public void function setDAO(DAO){
		variables.DAO = arguments.DAO;
	}

	public any function getIterator(required query qry){
		return variables.beanFactory.getBean("beanIterator")
										.init(variables.beanFactory)
										.setQuery(arguments.qry)
										.setEntityName(variables.entityName);
	}

	public any function delete(required any bean) {
		return variables.DAO.delete(bean);
	}

	public query function get() {
		return variables.DAO.get(argumentCollection=arguments);
	}

	public any function getBean() {
		if(!structKeyExists(arguments, variables.entityName & "ID"))
			throw(message="please provide #variables.entityName#ID", type="interface");
		var qry = variables.DAO.get(argumentCollection=arguments);
		var bean = variables.beanFactory.getBean(variables.entityName);
		if(qry.recordCount){
			bean.set(qry)
				.setValue("isNew", 0);
		} else{
			bean.setValue("isNew", 1);
		}
		return bean;
	}

	public any function getNew() {
		return variables.beanFactory.getBean(variables.entityName);
	}

	public any function save(required any bean) {
		return variables.DAO.save(bean);
	}

}
