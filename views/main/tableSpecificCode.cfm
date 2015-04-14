<div class="posts">
	<h1 class="content-subhead">
		MVC ColdFusion Application Generator
	</h1>

	<section class="post">
		<header class="post-header">
			<h2 class="post-title">
				Generated Output
			</h2>
		</header>
		<cfset generator = CreateObject("component", "generator").init(dsn=#rc.dsn#,
		                                                               siteTitle=#rc.siteTitle#,
		                                                               table=#rc.table#)/>
		<cfset tableColumns = generator.getColumns(rc.table)>

		<div id="accordion">
			<h3>
				<cfoutput>#generator.decamelizeString(rc.table)#</cfoutput>
				Specific Data Files
			</h3>
			<div>
				<div class="tabs">
					<ul>
						<cfoutput>
							<li>
								<a href="##tabs-structure">
									Table Structure
								</a>
							</li>
							<li>
								<a href="##tabs-bean">
									#rc.table#.cfc (bean)
								</a>
							</li>
							<li>
								<a href="##tabs-controller">
									#rc.table#.cfc (controller)
								</a>
							</li>
							<li>
								<a href="##tabs-service">
									#rc.table#Service.cfc
								</a>
							</li>
							<li>
								<a href="##tabs-dao">
									#rc.table#DAO.cfc
								</a>
							</li>
						</cfoutput>
					</ul>

					<div id="tabs-structure">
						<table id="tableData" class="display" border="0" cellpadding="5"
						       cellspacing="0">
							<thead>
								<tr>
									<th>
										Column Name
									</th>
									<th>
										Data Type
									</th>
									<th>
										Column Size
									</th>
									<th>
										Is Nullable
									</th>
									<th>
										Is Primary Key
									</th>
								</tr>
							</thead>
							<tbody>
								<cfoutput query="tableColumns">
									<tr>
										<td>
											#column_name#
										</td>
										<td>
											#type_name#
										</td>
										<td>
											#column_size#
										</td>
										<td>
											#is_nullable#
										</td>
										<td>
											#is_primarykey#
										</td>
									</tr>
								</cfoutput>
							</tbody>
						</table>
					</div>

					<div id="tabs-bean">
						<cfset getBean = generator.generateBean()>
						<cfoutput>
							<span style="color:##000099; font-weight:bold;">
								Click inside code box to select all
							</span>
							<textarea onclick="this.focus();this.select()" style="font-size: 8pt; width: 100%;" wrap="hard" rows="33" name="linkNode">#getBean#</textarea>
						</cfoutput>
					</div>

					<div id="tabs-controller">
						<cfset getController = generator.generateController()>
						<cfoutput>
							<span style="color:##000099; font-weight:bold;">
								Click inside code box to select all
							</span>
							<textarea onclick="this.focus();this.select()" style="font-size: 8pt; width: 100%;"
							          wrap="hard" rows="33" name="linkNode">#getController#</textarea>
						</cfoutput>
					</div>

					<div id="tabs-service">
						<cfset getService = generator.generateService()>
						<cfoutput>
							<span style="color:##000099; font-weight:bold;">
								Click inside code box to select all
							</span>
							<textarea onclick="this.focus();this.select()" style="font-size: 8pt; width: 100%;"
							          wrap="hard" rows="33" name="linkNode">#getService#</textarea>
						</cfoutput>
					</div>

					<div id="tabs-dao">
						<cfset getDAO = generator.generateDAO()>
						<cfoutput>
							<span style="color:##000099; font-weight:bold;">
								Click inside code box to select all
							</span>
							<textarea onclick="this.focus();this.select()" style="font-size: 8pt; width: 100%;"
							          wrap="hard" rows="33" name="linkNode">#getDAO#</textarea>
						</cfoutput>
					</div>
				</div>
			</div>

			<h3>
				<cfoutput>#generator.decamelizeString(rc.table)#</cfoutput>
				Specific View Files
			</h3>
			<div>
				<div class="tabs">
					<ul>
						<li>
							<a href="#tabs-table">default.cfm</a>
						</li>
						<li>
							<a href="#tabs-create">create.cfm</a>
						</li>
						<li>
							<a href="#tabs-update">update.cfm</a>
						</li>
						<li>
							<a href="#tabs-view">view.cfm</a>
						</li>
						<li>
							<a href="#tabs-viewedit">viewEdit.cfm</a>
						</li>
					</ul>

					<div id="tabs-table">
						<cfset getDataTable = generator.generateDataTable()>
						<cfoutput>
							<span style="color:##000099; font-weight:bold;">
								Click inside code box to select all
							</span>
							<textarea onclick="this.focus();this.select()" style="font-size: 8pt; width: 100%;"
							          wrap="hard" rows="33" name="linkNode">#getDataTable#</textarea>
						</cfoutput>
					</div>

					<div id="tabs-create">
						<cfset getCreateForm = generator.generateCreateForm()>
						<cfoutput>
							<span style="color:##000099; font-weight:bold;">
								Click inside code box to select all
							</span>
							<textarea onclick="this.focus();this.select()" style="font-size: 8pt; width: 100%;"
							          wrap="hard" rows="33" name="linkNode">#getCreateForm#</textarea>
						</cfoutput>
					</div>

					<div id="tabs-update">
						<cfset getUpdateForm = generator.generateUpdateForm()>
						<cfoutput>
							<span style="color:##000099; font-weight:bold;">
								Click inside code box to select all
							</span>
							<textarea onclick="this.focus();this.select()" style="font-size: 8pt; width: 100%;"
							          wrap="hard" rows="33" name="linkNode">#getUpdateForm#</textarea>
						</cfoutput>
					</div>

					<div id="tabs-view">
						<cfset getView = generator.generateView()>
						<cfoutput>
							<span style="color:##000099; font-weight:bold;">
								Click inside code box to select all
							</span>
							<textarea onclick="this.focus();this.select()" style="font-size: 8pt; width: 100%;"
							          wrap="hard" rows="33" name="linkNode">#getView#</textarea>
						</cfoutput>
					</div>

					<div id="tabs-viewedit">
						<cfset getViewEdit = generator.generateViewEdit()>
						<cfoutput>
							<span style="color:##000099; font-weight:bold;">
								Click inside code box to select all
							</span>
							<textarea onclick="this.focus();this.select()" style="font-size: 8pt; width: 100%;"
							          wrap="hard" rows="33" name="linkNode">#getViewEdit#</textarea>
						</cfoutput>
					</div>
				</div>
			</div>
		</div>
	</section>
</div>
