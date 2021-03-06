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
package com.dell.research.bc.eth.solidity.editor

import com.dell.research.bc.eth.solidity.editor.solidity.And
import com.dell.research.bc.eth.solidity.editor.solidity.Assignment
import com.dell.research.bc.eth.solidity.editor.solidity.BinaryNotExpression
import com.dell.research.bc.eth.solidity.editor.solidity.BooleanConst
import com.dell.research.bc.eth.solidity.editor.solidity.Comparison
import com.dell.research.bc.eth.solidity.editor.solidity.Equality
import com.dell.research.bc.eth.solidity.editor.solidity.Ether
import com.dell.research.bc.eth.solidity.editor.solidity.Expression
import com.dell.research.bc.eth.solidity.editor.solidity.SpecialVariables
import com.dell.research.bc.eth.solidity.editor.solidity.NewExpression
import com.dell.research.bc.eth.solidity.editor.solidity.NotExpression
import com.dell.research.bc.eth.solidity.editor.solidity.Now
import com.dell.research.bc.eth.solidity.editor.solidity.NumberDimensionless
import com.dell.research.bc.eth.solidity.editor.solidity.Or
import com.dell.research.bc.eth.solidity.editor.solidity.SolidityFactory
import com.dell.research.bc.eth.solidity.editor.solidity.SolidityPackage
import com.dell.research.bc.eth.solidity.editor.solidity.StringLiteral
import com.dell.research.bc.eth.solidity.editor.solidity.Time
import com.dell.research.bc.eth.solidity.editor.solidity.Tuple
import com.dell.research.bc.eth.solidity.editor.solidity.TypeCast
import com.dell.research.bc.eth.solidity.editor.solidity.VariableDeclarationExpression

class SolidityTypeProvider {

	public static val booleanType = SolidityFactory.eINSTANCE.createContractOrLibrary => [name = "booleanType"]
	public static val tupleType = SolidityFactory.eINSTANCE.createContractOrLibrary => [
		name = "tupleType"
	]
	public static val numberDimensionlessType = SolidityFactory.eINSTANCE.createContractOrLibrary => [
		name = "numberDimensionlessType"
	]
	public static val stringType = SolidityFactory.eINSTANCE.createContractOrLibrary => [
		name = "stringType"
	]
	public static val intType = SolidityFactory.eINSTANCE.createContractOrLibrary => [
		name = "intType"
	]
	public static val byteType = SolidityFactory.eINSTANCE.createContractOrLibrary => [
		name = "byteType"
	]
	public static val addressType = SolidityFactory.eINSTANCE.createContractOrLibrary => [
		name = "addressType"
	]

	// The Ether, Time and TypeCast probably need to be expanded to include
	// the different sub-domains. DAF
	public static val etherType = SolidityFactory.eINSTANCE.createContractOrLibrary => [
		name = "etherType"
	]
	public static val timeType = SolidityFactory.eINSTANCE.createContractOrLibrary => [
		name = "timeType"
	]
	public static val typeCastType = SolidityFactory.eINSTANCE.createContractOrLibrary => [
		name = "typeCastType"
	]

	def typeFor(Expression e) {
		switch (e) {
			Or: booleanType
			And: booleanType
			Equality: booleanType
			Comparison: booleanType
			NotExpression: booleanType
			BinaryNotExpression: booleanType
			NewExpression: e.contract
			Tuple: tupleType
			BooleanConst: booleanType
			StringLiteral: stringType
			NumberDimensionless: numberDimensionlessType
			Ether: etherType
			Time: timeType
			TypeCast: typeCastType
			SpecialVariables: specialVariablesType(e)
			Now : intType
			default: booleanType
		} // switch
	} // typeFor

	def expectedType(Expression e) {
		val c = e.eContainer
		val f = e.eContainingFeature

		switch (c) {
			VariableDeclarationExpression case f == SolidityPackage::VARIABLE_DECLARATION_EXPRESSION: c.type.typeFor
			Assignment case f == SolidityPackage::ASSIGNMENT__LEFT: c.left.typeFor
			NewExpression case f == SolidityPackage::VARIABLE_DECLARATION_EXPRESSION__TYPE: c.contract
			case f == SolidityPackage::IF_STATEMENT__CONDITION: booleanType
		} // switch
	} // expectedType


	private def specialVariablesType(SpecialVariables sv) {
		switch (sv.type) {
			case MSG:
				switch (sv.field) {
					case "data": byteType
					case "gas": intType
					case "sender": addressType
					case "sig": byteType
					case "value": intType
				}
			case BLOCK:
				switch (sv.field) {
					case "blockhash": intType
					case "coinbase": addressType
					case "difficulty": intType
					case "gaslimit": intType
					case "number": intType
					case "timestamp": intType
				}
			case TX:
				switch (sv.field) {
					case "gasprice": intType
					case "origin": addressType
				}
		}
	}
} // SolidityTypeProvider