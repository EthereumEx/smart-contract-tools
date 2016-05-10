/*******************************************************************************
 * Copyright (c) 2016 Keoja LLC and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *     Daniel Ford, Keoja LLC
 *******************************************************************************/
package com.dell.research.bc.eth.solidity.editor.generator.go

import com.dell.research.bc.eth.solidity.editor.solidity.Assignment
import com.dell.research.bc.eth.solidity.editor.solidity.Expression
import com.dell.research.bc.eth.solidity.editor.solidity.ExpressionStatement
import com.dell.research.bc.eth.solidity.editor.solidity.FunctionDefinition
import com.dell.research.bc.eth.solidity.editor.solidity.QualifiedIdentifier
import com.dell.research.bc.eth.solidity.editor.solidity.StandardVariableDeclaration
import com.dell.research.bc.eth.solidity.editor.solidity.Statement
import com.dell.research.bc.eth.solidity.editor.solidity.VarVariableDeclaration
import com.dell.research.bc.eth.solidity.editor.solidity.VarVariableTupleVariableDeclaration
import org.eclipse.emf.common.util.BasicEList
import org.eclipse.emf.common.util.EList

class Utilities {
	/**
	 * Extract the names of the variables from the variable declarations.
	 */
	static def EList<String> getVarNames(EList<Statement> variableDeclarations) {
		var ret = new BasicEList<String>()
		for (statement : variableDeclarations) {
			ret.add(
				switch statement {
					StandardVariableDeclaration: statement.variable.name
					VarVariableDeclaration: "varavar not implemented yet"
					VarVariableTupleVariableDeclaration: "vvartup  not implemented yet"
				}
			)
		}
		ret
	} // getVarNames

	static def EList<FunctionDefinition> getInvocableFunctions(EList<FunctionDefinition> functions,
		EList<String> varNames) {
		var ret = new BasicEList<FunctionDefinition>
		for (function : functions) {
			if (hasVariableAssignment(function, varNames)) {
				ret.add(function)
			}
		}
		ret
	} // getInvocableFunctions

	static def EList<FunctionDefinition> getQueryableFunctions(EList<FunctionDefinition> functions,
		EList<String> varNames) {
		var ret = new BasicEList<FunctionDefinition>
		for (function : functions) {
			if (!hasVariableAssignment(function, varNames)) {
				ret.add(function)
			}
		}
		ret
	} // getQueryableFunctions

	/**
	 * Return true if the FunctionDefinition assigns to a variable.
	 */
	static def boolean hasVariableAssignment(FunctionDefinition function, EList<String> varNames) {
		var ret = false
		for (stmt : function.block.statements) {
			switch stmt {
				ExpressionStatement:
					switch expr : stmt.expression {
						Assignment: ret = varNames.contains((expr.left as QualifiedIdentifier).identifier)
					}
			}

			if (ret) {
				return true;
			}
		}
		ret
	} // hasVariableAssignment

	static def extractValue(Expression expr) {
		switch expr {
			QualifiedIdentifier: expr.identifier
			default: expr.toString
		}
	} // extractValue
} // Utilities
