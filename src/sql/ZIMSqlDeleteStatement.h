/*
 * Copyright 2011 Ziminji
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZIMSqlStatement.h"
#import "ZIMSqlDataManipulationCommand.h"

/*!
 @class					ZIMSqlDeleteStatement
 @discussion			This class represents an SQL delete statement.
 @updated				2011-07-15
 @see					http://www.sqlite.org/lang_delete.html
 */
@interface ZIMSqlDeleteStatement : NSObject <ZIMSqlStatement, ZIMSqlDataManipulationCommand> {

	@protected
		NSString *_table;
		NSMutableArray *_where;
		NSMutableArray *_orderBy;
		NSInteger _limit;
		NSInteger _offset;

}

/*!
 @method				table:
 @discussion			This method will set the table used in the SQL statement.
 @param table			The table that will be used in the SQL statement.
 @updated				2011-10-30
 */
- (void) table: (NSString *)table;
/*!
 @method				whereBlock:
 @discussion			This method will start or end a block.
 @param brace			The brace to be used; it is either an opening or closing brace.
 @updated				2011-03-13
 */
- (void) whereBlock: (NSString *)brace;
/*!
 @method				whereBlock:connector:
 @discussion			This method will start or end a block.
 @param brace			The brace to be used; it is either an opening or closing brace.
 @param connector		The connector to be used.
 @updated				2011-04-01
 */
- (void) whereBlock: (NSString *)brace connector: (NSString *)connector;
/*!
 @method				where:operator:column:
 @discussion			This method will add a where clause to the SQL statement.
 @param column1			The column to be tested.
 @param operator		The operator to be used.
 @param column2			The column to be compared.
 @updated				2011-04-01
 */
- (void) where: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2;
/*!
 @method				where:operator:column:connector:
 @discussion			This method will add a where clause to the SQL statement.
 @param column1			The column to be tested.
 @param operator		The operator to be used.
 @param column2			The column to be compared.
 @param connector		The connector to be used.
 @updated				2011-05-19
 */
- (void) where: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2 connector: (NSString *)connector;
/*!
 @method				where:operator:value:
 @discussion			This method will add a where clause to the SQL statement.
 @param column			The column to be tested.
 @param operator		The operator to be used.
 @param value			The value to be compared.
 @updated				2011-04-01
 */
- (void) where: (NSString *)column operator: (NSString *)operator value: (id)value; // wrap primitives with NSNumber
/*!
 @method				where:operator:value:connector:
 @discussion			This method will add a where clause to the SQL statement.
 @param column			The column to be tested.
 @param operator		The operator to be used.
 @param value			The value to be compared.
 @param connector		The connector to be used.
 @updated				2011-05-19
 */
- (void) where: (NSString *)column operator: (NSString *)operator value: (id)value connector: (NSString *)connector; // wrap primitives with NSNumber
/*!
 @method				orderBy:
 @discussion			This method will add an order by clause to the SQL statement.
 @param column			The column to be ordered.
 @updated				2011-11-05
 */
- (void) orderBy: (NSString *)column; // ORDER BY [COLUMN NAME]
/*!
 @method				orderBy:descending:
 @discussion			This method will add an order by clause to the SQL statement.
 @param column			The column to be ordered.
 @param descending		This will determine whether the column should be ordered in descending order.
 @updated				2011-11-05
 */
- (void) orderBy: (NSString *)column descending: (BOOL)descending; // ORDER BY [COLUMN NAME] [ASC | DESC]
/*!
 @method				orderBy:nulls:
 @discussion			This method will add an order by clause to the SQL statement.
 @param column			The column to be ordered.
 @param weight			This indicates how nulls are to be weighed when comparing with non-nulls.
 @updated				2011-11-05
 @see					http://sqlite.org/cvstrac/wiki?p=UnsupportedSql
 @see					https://hibernate.onjira.com/browse/HHH-465
 @see					http://sqlblog.com/blogs/denis_gobo/archive/2007/10/19/3048.aspx
 */
- (void) orderBy: (NSString *)column nulls: (NSString *)weight; // ORDER BY [COLUMN NAME] [NULLS FIRST | NULLS LAST]
/*!
 @method				orderBy:descending:nulls:
 @discussion			This method will add an order by clause to the SQL statement.
 @param column			The column to be ordered.
 @param descending		This will determine whether the column should be ordered in descending order.
 @param weight			This indicates how nulls are to be weighed when comparing with non-nulls.
 @updated				2011-11-05
 @see					http://sqlite.org/cvstrac/wiki?p=UnsupportedSql
 @see					https://hibernate.onjira.com/browse/HHH-465
 @see					http://sqlblog.com/blogs/denis_gobo/archive/2007/10/19/3048.aspx
 */
- (void) orderBy: (NSString *)column descending: (BOOL)descending nulls: (NSString *)weight; // ORDER BY [COLUMN NAME] [ASC | DESC] [NULLS FIRST | NULLS LAST]
/*!
 @method				limit:
 @discussion			This method will add a limit clause to the SQL statement.
 @param limit			The number of records to be returned.
 @updated				2011-06-27
 */
- (void) limit: (NSInteger)limit;
/*!
 @method				offset:
 @discussion			This method will add an offset clause to the SQL statement.
 @param offset			The starting point to start evaluating.
 @updated				2011-06-27
 */
- (void) offset: (NSInteger)offset;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-10-19
 */
- (NSString *) statement;

@end
