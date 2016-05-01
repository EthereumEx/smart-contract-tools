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

import com.dell.research.bc.eth.solidity.editor.solidity.Assignment
import com.dell.research.bc.eth.solidity.editor.solidity.Contract
import com.dell.research.bc.eth.solidity.editor.solidity.DefinitionBody
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
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import com.dell.research.bc.eth.solidity.editor.solidity.ReturnStatement

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class SolidityGenerator implements IGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess fsa) {

		resource.allContents.filter(Contract).forall [
			val varNames = getVarNames(it.body.variables)

			val invocableFunctions = getInvocableFunctions(it.body.functions, varNames)
			val queryableFunctions = getQueryableFunctions(it.body.functions, varNames)

			fsa.generateFile(
				it.name + '.go',
				'''
					«doFileHeader()»
					«doFuncInit(it.body)»
					«doFuncInvoke(invocableFunctions)»
					«doFuncQuery(queryableFunctions)»
					«doFunctions(it.body.functions)»
					«doWriteFunc»
					«doReadFunc»
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

	def EList<String> getVarNames(EList<Statement> variableDeclarations) {
		var ret = new BasicEList<String>()
		for (statement : variableDeclarations) {
			ret.add(
				switch statement {
					StandardVariableDeclaration: statement.variable.name
					VarVariableDeclaration: "varavar"
					VarVariableTupleVariableDeclaration: "vvartup"
				}
			)
		}
		ret
	}

	def EList<FunctionDefinition> getInvocableFunctions(EList<FunctionDefinition> functions, EList<String> varNames) {
		var ret = new BasicEList<FunctionDefinition>
		for (function : functions) {
		   if (hasVariableAssignment(function,varNames)) {
		   	  ret.add(function)
		   }			
		}
		ret
	}
	

	def EList<FunctionDefinition> getQueryableFunctions(EList<FunctionDefinition> functions, EList<String> varNames) {
		var ret = new BasicEList<FunctionDefinition>
		for (function : functions) {
		   if (!hasVariableAssignment(function,varNames)) {
		   	  ret.add(function)
		   }			
		}
		ret
	}

	def boolean hasVariableAssignment(FunctionDefinition function, EList<String> varNames) {
		var ret = false
		for (stmt : function.block.statements) {
			switch stmt {
				ExpressionStatement: switch expr : stmt.expression {
					Assignment: ret = varNames.contains((expr.left as QualifiedIdentifier).identifier)
				}
			}
			
			if (ret) {
				return true;
			}
		}
		ret
	}
	
	def doFileHeader() {
		'''
			package main
			import (
					"errors"
					"fmt"
							
					"github.com/hyperledger/fabric/core/chaincode/shim"
			)
			
			SimpleChaincode example simple Chaincode implementation
			 			type SimpleChaincode struct {
			}
			
			// =======================
			// Main
			// =======================
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
				
			}
			
		'''
	}

	// «doInvokeClause(functions.get(0))»
	def doFuncInvoke(EList<FunctionDefinition> functions) {
		'''
		// ============================================================================================================================
		// Invoke - Our entry point
		// ============================================================================================================================
		func (t *SimpleChaincode) Invoke(stub *shim.ChaincodeStub, function string, args []string) ([]byte, error) {
			// Handle different functions
			if function == "init" {
				return t.Init(stub, "init", args)
			} 
			«FOR f : functions BEFORE 'else '»
				«doInvokeClause(f)»
			«ENDFOR»
			fmt.Println("invoke did not find func: " + function)
			
			return nil, errors.New("Received unknown function invocation")
		}
			
		'''
	}

	def doInvokeClause(FunctionDefinition function) {
		'''
		if function == "«function.name»" {
		  return t.«function.name»(stub, args)
		}
		'''
	}

	def doFuncQuery(EList<FunctionDefinition> functions) {
		'''
			// ============================================================================================================================
			// Query - Our entry point for Queries
			// ============================================================================================================================
			func (t *SimpleChaincode) Query(stub *shim.ChaincodeStub, function string, args []string) ([]byte, error) {
				// Handle different functions
				«FOR f : functions»
					«doInvokeClause(f)»
				«ENDFOR»
				fmt.Println("query did not find func: " + function)
				
				return nil, errors.New("Received unknown function query")
			}
			
		'''
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
				«FOR stmt : function.block.statements»
					«IF stmt instanceof ExpressionStatement»
					  write("«((stmt.expression as Assignment).left as QualifiedIdentifier).identifier »", «extractValue((stmt.expression as Assignment).expression)»)
					«ELSEIF stmt instanceof ReturnStatement»
					  read("«extractValue((stmt as ReturnStatement).expression)»")
					«ELSE»
					  stmt.toString
					«ENDIF»
							
				«ENDFOR»
			}
		'''
	}

	def extractValue(Expression expr) {
		switch expr {
			QualifiedIdentifier: expr.identifier
			default: expr.toString
		}
	}

	def doWriteFunc() {'''
	// ============================================================================================================================
	// write - invoke function to write key/value pair
	// ============================================================================================================================
	func (t *SimpleChaincode) write(stub *shim.ChaincodeStub, args []string) ([]byte, error) {
		var name, value string
		var err error
		fmt.Println("running write()")
	
		if len(args) != 2 {
			return nil, errors.New("Incorrect number of arguments. Expecting 2. name of the variable and value to set")
		}
	
		name = args[0]                            //rename for funsies
		value = args[1]
		err = stub.PutState(name, []byte(value))  //write the variable into the chaincode state
		if err != nil {
			return nil, err
		}
		return nil, nil
	}
	'''
		
	}
	
	def doReadFunc() {'''
	// ============================================================================================================================
	// read - query function to read key/value pair
	// ============================================================================================================================
	func (t *SimpleChaincode) read(stub *shim.ChaincodeStub, args []string) ([]byte, error) {
		var name, jsonResp string
		var err error
	
		if len(args) != 1 {
			return nil, errors.New("Incorrect number of arguments. Expecting name of the var to query")
		}
	
		name = args[0]
		valAsbytes, err := stub.GetState(name)
		if err != nil {
			jsonResp = "{\"Error\":\"Failed to get state for " + name + "\"}"
			return nil, errors.New(jsonResp)
		}
	
		return valAsbytes, nil
	}
	
	'''
		
	}
} // SolidityGenerator
