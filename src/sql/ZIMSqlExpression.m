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

#import <sqlite3.h> // Requires libsqlite3.dylib
#import "NSString+ZIMString.h"
#import "ZIMSqlExpression.h"
#import "ZIMSqlSelectStatement.h"

NSString *ZIMSqlDefaultValue(id value) {
	if ((value == nil) || [value isKindOfClass: [NSNull class]]) {
		return @"DEFAULT NULL";
	}
	else if ([value isKindOfClass: [NSNumber class]]) {
		return [NSString stringWithFormat: @"DEFAULT %@", value];
	}
	else if ([value isKindOfClass: [NSString class]]) {
		char *escapedValue = sqlite3_mprintf("DEFAULT '%q'", [(NSString *)value UTF8String]);
		NSString *string = [NSString stringWithUTF8String: (const char *)escapedValue];
		sqlite3_free(escapedValue);
		return string;
	}
	else if ([value isKindOfClass: [NSData class]]) {
		NSData *data = (NSData *)value;
		int length = [data length];
		NSMutableString *buffer = [[NSMutableString alloc] init];
		[buffer appendString: @"DEFAULT '"];
		const unsigned char *dataBuffer = [data bytes];
		for (int i = 0; i < length; i++) {
			[buffer appendFormat: @"%02x", (unsigned long)dataBuffer[i]];
		}
		[buffer appendString: @"'"];
		return buffer;
	}
	else if ([value isKindOfClass: [NSDate class]]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
		NSString *date = [NSString stringWithFormat: @"DEFAULT '%@'", [formatter stringFromDate: (NSDate *)value]];
		return date;
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: [NSString stringWithFormat: @"Unable to set default value. '%@'", value] userInfo: nil];
	}
}

NSString *ZIMSqlDataTypeChar(NSInteger x) {
	return [NSString stringWithFormat: @"CHAR(%d)", x];
}

NSString *ZIMSqlDataTypeCharacter(NSInteger x) {
	return [NSString stringWithFormat: @"CHARACTER(%d)", x];
}

NSString *ZIMSqlDataTypeDecimal(NSInteger x, NSInteger y) {
	return [NSString stringWithFormat: @"DECIMAL(%d, %d)", x, y];
}

NSString *ZIMSqlDataTypeNativeCharacter(NSInteger x) {
	return [NSString stringWithFormat: @"NATIVE CHARACTER(%d)", x];
}

NSString *ZIMSqlDataTypeNChar(NSInteger x) {
	return [NSString stringWithFormat: @"NCHAR(%d)", x];
}

NSString *ZIMSqlDataTypeNVarChar(NSInteger x) {
	return [NSString stringWithFormat: @"NVARCHAR(%d)", x];
}

NSString *ZIMSqlDataTypeVarChar(NSInteger x) {
	return [NSString stringWithFormat: @"VARCHAR(%d)", x];
}

NSString *ZIMSqlDataTypeVaryingCharacter(NSInteger x) {
	return [NSString stringWithFormat: @"VARYING CHARACTER(%d)", x];
}

@implementation ZIMSqlExpression

+ (NSString *) prepareConnector: (NSString *)token {
	if (![token matchRegex: @"^(and|or)$" options: NSRegularExpressionCaseInsensitive]) {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid connector token provided." userInfo: nil];
	}
	return [token uppercaseString];
}

+ (NSString *) prepareEnclosure: (NSString *)token {
	if (!([token isEqualToString: ZIMSqlEnclosureOpeningBrace] || [token isEqualToString: ZIMSqlEnclosureClosingBrace])) {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid enclosure token provided." userInfo: nil];
	}
	return token;
}

+ (NSString *) prepareIdentifier: (NSString *)identifier {
	if ([identifier matchRegex: @"^select .+$" options: NSRegularExpressionCaseInsensitive]) {
		identifier = [identifier stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @" ;()\n\r\t\f"]];
		identifier = [NSString stringWithFormat: @"(%@)", identifier];
	}
	return identifier;
}

+ (NSString *) prepareIdentifier: (NSString *)identifier maxCount: (NSUInteger)count {
	NSMutableString *buffer = [[NSMutableString alloc] init];
	NSArray *tokens = [identifier componentsSeparatedByString: @"."];
	int length = [tokens count];
	int start = length - MIN(count, length);
	NSError *error;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: @"[^a-z0-9_ ]" options: NSRegularExpressionCaseInsensitive error: &error];
	for (int index = start; index < length; index++) {
		NSString *token = [tokens objectAtIndex: index];
		token = [regex stringByReplacingMatchesInString: token options: 0 range: NSMakeRange(0, [token length]) withTemplate: @""];
		token = [token stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if (index > start) {
			[buffer appendString: @"."];
		}
		[buffer appendFormat: @"[%@]", token];
	}
	return buffer;
}

+ (NSString *) prepareJoinType: (NSString *)token {
	if ((token == nil) || [token isEqualToString: ZIMSqlJoinTypeNone]) {
		token = ZIMSqlJoinTypeInner;
	}
	else if ([token isEqualToString: @","]) {
		token = ZIMSqlJoinTypeCross;
	}
	if (![token matchRegex: @"^((natural )?(cross|inner|(left( outer)?)))|(natural)$" options: NSRegularExpressionCaseInsensitive]) {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid join type token provided." userInfo: nil];
	}
	return [token uppercaseString];
}

+ (NSInteger) prepareNaturalNumber: (NSInteger)number {
	return abs(number);
}

+ (NSString *) prepareOperator: (NSString *)operator ofType: (NSString *)type {
	if ([[type uppercaseString] isEqualToString: @"SET"] && ![operator matchRegex: @"^(except|intersect|(union( all)?))$" options: NSRegularExpressionCaseInsensitive]) {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid set operator token provided." userInfo: nil];
	}
	return [operator uppercaseString];
}

+ (NSString *) prepareSortOrder: (BOOL)descending {
	return (descending) ? @"DESC" : @"ASC";
}

+ (NSString *) prepareSortWeight: (NSString *)weight {
	if (weight != nil) {
		if (![weight matchRegex: @"^(first|last)$" options: NSRegularExpressionCaseInsensitive]) {
			@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid weight token provided." userInfo: nil];
		}
		return [weight uppercaseString];
	}
	return @"DEFAULT";
}

+ (NSString *) prepareValue: (id)value {
	if ((value == nil) || [value isKindOfClass: [NSNull class]]) {
		return @"NULL";
	}
	else if ([value isKindOfClass: [ZIMSqlSelectStatement class]]) {
		NSString *statement = [(ZIMSqlSelectStatement *)value statement];
		statement = [statement substringWithRange: NSMakeRange(0, [statement length] - 1)];
		statement = [NSString stringWithFormat: @"(%@)", statement];
		return statement;
	}
	else if ([value isKindOfClass: [NSArray class]]) {
		NSMutableString *str = [[NSMutableString alloc] init];
		[str appendString: @"("];
		for (int i = 0; i < [value count]; i++) {
			if (i > 0) {
				[str appendString: @", "];
			}
			[str appendString: [self prepareValue: [value objectAtIndex: i]]];
		}
		[str appendString: @")"];
		return str;
	}
	else if ([value isKindOfClass: [NSNumber class]]) {
		return [NSString stringWithFormat: @"%@", value];
	}
	else if ([value isKindOfClass: [NSString class]]) {
		char *escapedValue = sqlite3_mprintf("'%q'", [(NSString *)value UTF8String]);
		NSString *string = [NSString stringWithUTF8String: (const char *)escapedValue];
		sqlite3_free(escapedValue);
		return string;
	}
	else if ([value isKindOfClass: [NSData class]]) {
		NSData *data = (NSData *)value;
		int length = [data length];
		NSMutableString *buffer = [[NSMutableString alloc] init];
		[buffer appendString: @"'"];
		const unsigned char *dataBuffer = [data bytes];
		for (int i = 0; i < length; i++) {
			[buffer appendFormat: @"%02x", (unsigned long)dataBuffer[i]];
		}
		[buffer appendString: @"'"];
		return buffer;
	}
	else if ([value isKindOfClass: [NSDate class]]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
		NSString *date = [NSString stringWithFormat: @"'%@'", [formatter stringFromDate: (NSDate *)value]];
		return date;
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: [NSString stringWithFormat: @"Unable to prepare value. '%@'", value] userInfo: nil];
	}
}

@end
