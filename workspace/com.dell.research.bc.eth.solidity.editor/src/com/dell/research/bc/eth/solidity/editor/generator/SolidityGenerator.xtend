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

import com.dell.research.bc.eth.solidity.editor.generator.go.SolidityToGoGenerator
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class SolidityGenerator implements IGenerator {

	val doGenerateGo = true
	val goGenerator = new SolidityToGoGenerator
	
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {

		if (doGenerateGo) {
			goGenerator.doGenerate(resource,fsa)
		}

	} // doGenerate

	
} // SolidityGenerator
