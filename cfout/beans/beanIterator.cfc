<cfcomponent extends="mura.iterator.queryIterator" output="false">

<cfset variables.entityName="bean">


<cffunction name="init" output="false">
	<cfargument name="beanFactory" required="true" type="any">
	<cfset variables.beanFactory = arguments.beanFactory>
	<cfset super.init()>
	<cfreturn this>
</cffunction>

<cffunction name="setEntityName" output="false">
	<cfargument name="entityName">
	<cfif len(arguments.entityName)>
		<cfset variables.entityName=arguments.entityName>
	</cfif>
	<cfreturn this>
</cffunction>

<cffunction name="getEntityName" output="false">
	<cfreturn variables.entityName>
</cffunction>

<cffunction name="packageRecord" access="public" output="false" returntype="any">
	<cfargument name="recordIndex" default="#currentIndex()#">
	<cfset var bean="">

	<cfif isQuery(variables.records)>
		<cfreturn variables.beanFactory.getBean(variables.entityName).set(queryRowToStruct(variables.records,arguments.recordIndex)).setIsNew(0)>
	<cfelseif isArray(variables.records)>
		<cfset bean=variables.records[arguments.recordIndex]>
		<cfif isObject(bean)>
			<cfreturn bean>
		<cfelse>
			<cfreturn variables.beanFactory.getBean(variables.entityName).set(bean)>
		</cfif>
	<cfelse>
		<cfthrow message="The records have not been set.">
	</cfif>
</cffunction>

</cfcomponent>