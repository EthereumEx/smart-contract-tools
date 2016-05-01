/*******************************************************************************
 * Copyright (c) 2015 Dell Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *     Daniel Ford, Dell Corporation - initial API and implementation
 *******************************************************************************/
package com.dell.research.bc.eth.solidity.editor.generator

import com.dell.research.bc.eth.solidity.editor.solidity.Contract
import com.dell.research.bc.eth.solidity.editor.solidity.DefinitionBody
import com.dell.research.bc.eth.solidity.editor.solidity.FunctionDefinition
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class SolidityGenerator implements IGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess fsa) {

		//var foo = resource.getAllContents();
		resource.allContents.filter(Contract).forall [

			fsa.generateFile(
				it.name + '.go',
				'''
					«doFileHeader()»
					«doFuncInit(it.body)»
					«doFuncInvoke(it.body.functions)»
					«doFuncQuery(it.body.functions)»
					«doFunctions(it.body.functions)»
				'''
//			+ 
//			resource.allContents
//				.filter(typeof(Greeting))
//				.map[name]
//				.join(', ')
			)
			true
		];

	}

	def doFileHeader() {
		'''
			package main
			import (
					"errors"
					"fmt"
							
					"github.com/hyperledger/fabric/core/chaincode/shim"
			)
			
			// SimpleChaincode example simple Chaincode implementation
			 			type SimpleChaincode struct {
			 	}
			
			// ============================================================================================================================
			// Main
			// ============================================================================================================================
			func main() {
			err := shim.Start(new(SimpleChaincode))
							if err != nil {
								fmt.Printf("Error starting Simple chaincode: %s", err)
			}
		'''
	}

	def doFuncInit(DefinitionBody body) {
		'''
		func (t *SimpleChaincode) Init(stub *shim.ChaincodeStub, function string, args []string) ([]byte, error) {
			
		}'''
	}

	// 
	def doFuncInvoke(EList<FunctionDefinition> functions) {
		'''
		func (t *SimpleChaincode) Invoke(stub *shim.ChaincodeStub, function string, args []string) ([]byte, error) {
			// Handle different functions
				if function == "init" {
					return t.Init(stub, "init", args)
				} 
				«functions.forEach[it.doInvokeClause()]»
				
				fmt.Println("invoke did not find func: " + function)
			
				return nil, errors.New("Received unknown function invocation")
		}'''
	}

	def doInvokeClause(FunctionDefinition function) {
		'''
			else if function == "«function.name»" {
			  return t.«function.name»(stub, args)
			}
		'''
	}

	def doFuncQuery(EList<FunctionDefinition> functions) {
		'''
		func (t *SimpleChaincode) Query(stub *shim.ChaincodeStub, function string, args []string) ([]byte, error) {
			
		}'''
	}

	def doFunctions(EList<FunctionDefinition> functions) {
		var ret = ""
		for (f : functions) {
			ret += doFunction(f)
		}
		ret
	}

	def doFunction(FunctionDefinition function) {
		'''
		func (t *SimpleChaincode) «function.name»(stub *shim.ChaincodeStub, args []string) ([]byte, error) {
			
		}'''
	}

// doGenerate
//
//	def doBody(DefinitionBody body) {
//		var ret = ''
//
//		for (vd : body.variables) {
//			ret += doVariableDeclaration(vd) + '\n'
//		}
//
//		for (function : body.functions) {
//			ret += doFunction(function) + '\n'
//		}
//
//		for (modifier : body.modifiers) {
//			ret += doModifier(modifier) + '\n'
//		}
//
//		for (enum : body.enums) {
//			ret += doEnum(enum) + '\n'
//		}
//
//		for (event : body.events) {
//			ret += doEvent(event) + '\n'
//		}
//		ret
//	} // doBody
//	
//	def doEnum(EnumDefinition definition) {
//		'''enum'''
//	}
//
//	def doEvent(Event event) { '''''' }
//
//	
//	def doModifier(Modifier modifier) {
//		'''modifier'''
//	}
//
//	def CharSequence doFunction(
//		FunctionDefinition fd) {
//		'''function «fd.name» «doParameterlist(fd.parameters)» «doFunctionDefinitionOptionalElements(fd.optionalElements)»{
//			 «doBlock(fd.block)»
//		}'''
//	} // doFunction
//
//	def doBlock(Block block) {
//		'''this is the body'''
//	} // doBlock
//
//	def doFunctionDefinitionOptionalElements(EList<FunctionDefinitionOptionalElement> list) {
//		var ret = ''
//		for (opElement : list) {
//			if (opElement instanceof Const) {
//				ret += "constant"
//			}
////			switch opElement {
////				case Const: 
////				default: ret += ''
////			}
//			ret += ' '
//		}
//		ret
//	} // doFunctionDefinitionOptionalElements	
//
//	def doParameterlist(ParameterList parameters) {
//		var varDefs = ''
//		for (vd : parameters.parameters) {
//			varDefs += doVariableDeclaration(vd)
//		}
//		'''(«varDefs»)'''
//	} // doParameterlist
//
//	def doVariableDefinition(Statement statement) {
//		'''foo'''
//	}
//
//	def doVariableDeclaration(Statement statement) {
//		switch statement {
//			 StandardVariableDeclaration: doStandardVariableDeclaration(statement)
//			 VarVariableDeclaration: 'varvariable'
//			 VarVariableTupleVariableDeclaration: "vartuple"
//			
//			default: ''
//		}
//	}
//	
//	def doStandardVariableDeclaration(StandardVariableDeclaration svd) {
//		var ret ='''«doStandardType(svd.type)» «doVariable(svd.variable)»'''
//		if (svd.expression != null) {
//			ret += ''' = «doExpression(svd.expression)»'''
//		}
//		ret
//	}
//	
//	def doVariable(Variable variable) {
//		variable.name
//	}
//	
//	def doStandardType(EObject object) {
//		'''standard'''
//	}
//	
//	
//	def doExpression(Expression expression) {
//		'''expression'''
//	}
} // SolidityGenerator
