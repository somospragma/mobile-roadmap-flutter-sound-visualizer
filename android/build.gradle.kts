// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Agregar las dependencias necesarias para el build
        // Usar versión 8.1.0 que es compatible con Gradle 8.9 y Java 17
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configuración opcional para el directorio de build
try {
    val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
    rootProject.layout.buildDirectory.set(newBuildDir)
    
    subprojects {
        val newSubprojectBuildDir = newBuildDir.dir(project.name)
        project.layout.buildDirectory.set(newSubprojectBuildDir)
    }
} catch (e: Exception) {
    // Manejar la excepción si ocurre algún problema con la configuración del directorio
    println("Error al configurar el directorio de build: ${e.message}")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
