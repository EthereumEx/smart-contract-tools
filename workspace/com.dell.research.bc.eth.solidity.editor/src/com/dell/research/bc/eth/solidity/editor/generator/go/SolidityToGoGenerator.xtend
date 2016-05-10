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
import com.dell.research.bc.eth.solidity.editor.solidity.Contract
import com.dell.research.bc.eth.solidity.editor.solidity.Expression
import com.dell.research.bc.eth.solidity.editor.solidity.ExpressionStatement
import com.dell.research.bc.eth.solidity.editor.solidity.FunctionDefinition
import com.dell.research.bc.eth.solidity.editor.solidity.QualifiedIdentifier
import com.dell.research.bc.eth.solidity.editor.solidity.ReturnStatement
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator

/**
 * This class generates code in the language "go" suitable to be used as "chaincode" for Hyperledger.
 * 
 * See: https://www.hyperledger.org/
 * 
 */
class SolidityToGoGenerator implements IGenerator {

	val PATH_PREFIX = 'go/'
	val FILE_SUFFIX = '.go'

	override doGenerate(Resource resource, IFileSystemAccess fsa) {
		resource.allContents.filter(Contract).forEach[doContract(it, fsa)]
	} // doGenerate

	def doContract(Contract contract, IFileSystemAccess fsa) {
		val varNames = Utilities.getVarNames(contract.body.variables)

		val invocableFunctions = Utilities.getInvocableFunctions(contract.body.functions, varNames)
		val queryableFunctions = Utilities.getQueryableFunctions(contract.body.functions, varNames)

		fsa.generateFile(
			PATH_PREFIX + contract.name + FILE_SUFFIX,
			'''
				«HyperledgerTemplates.doFileHeader()»
				«HyperledgerTemplates.doFuncInit(contract.body)»
				«HyperledgerTemplates.doFuncInvoke(invocableFunctions)»
				«HyperledgerTemplates.doFuncQuery(queryableFunctions)»
				«doFunctions(contract.body.functions)»
				«HyperledgerTemplates.doWriteFunc»
				«HyperledgerTemplates.doReadFunc»
			'''
		)
	} // doContract

	def doFunctions(EList<FunctionDefinition> functions) {
		var ret = ""
		for (f : functions) {
			ret += HyperledgerTemplates.doFunction(f)
		}
		ret
	} // doFunctions
	
} // SolidityToGoGenerator
