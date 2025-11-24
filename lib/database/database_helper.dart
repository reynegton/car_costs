// lib/database/database_helper.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// O nome do nosso banco de dados
const String _databaseName = "fuel_manager.db";

// RESETANDO PARA A VERSÃO 1:
// Todas as tabelas e colunas agora são criadas no _onCreate.
const int _databaseVersion = 2;

class DatabaseHelper {
  // ----------------------------------------------------
  // 1. Singleton (Garante que só há uma instância do banco)
  // ----------------------------------------------------
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Se o banco for null, inicializa ele
    _database = await _initDatabase();
    return _database!;
  }

  // ----------------------------------------------------
  // 2. Inicialização do Banco
  // ----------------------------------------------------
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Mantemos o onUpgrade para futuras alterações
    );
  }

  // ----------------------------------------------------
  // 3. onCREATE (VERSÃO FINAL CONSOLIDADA)
  // ----------------------------------------------------
  // Este método agora cria TODAS as tabelas e colunas.
  void _onCreate(Database db, int version) async {
    // Tabela de Veículos (V4 consolidada)
    await db.execute('''
      CREATE TABLE Veiculos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        marca TEXT,
        ano INTEGER,
        capacidadeTanqueLitros REAL,
        mediaManual REAL DEFAULT 0.0,
        kmAtual INTEGER DEFAULT 0,
        kmUltimoNivel INTEGER DEFAULT 0,
        litrosNoTanque REAL DEFAULT 0.0,
        mediaLongPrazo REAL DEFAULT 0.0
      )
    ''');

    // Tabela de Abastecimentos (V1 consolidada)
    await db.execute('''
      CREATE TABLE Abastecimentos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        veiculoId INTEGER,
        data TEXT,
        tipoCombustivel TEXT,
        kmAtual INTEGER,
        litrosAbastecidos REAL,
        valorPorLitro REAL,
        valorTotal REAL,
        tanqueCheio INTEGER, -- 0 ou 1
        mediaCalculada REAL
      )
    ''');

    // Tabela de Manutenções (V1 consolidada)
    await db.execute('''
      CREATE TABLE Manutencoes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        veiculoId INTEGER,
        data TEXT,
        valor REAL,
        descricao TEXT
      )
    ''');

    // Tabela de Configurações (V7 consolidada)
    await db.execute('''
      CREATE TABLE Configuracoes(
        id INTEGER PRIMARY KEY,
        mediaApuracaoN INTEGER,
        veiculoIdSelecionado INTEGER NULL,
        ultimoCombustivelId INTEGER NULL,
        encheuTanqueUltimoAbastecimento INTEGER DEFAULT 0
      )
    ''');
    // Insere o valor padrão (N=3) e demais defaults
    await db.insert('Configuracoes', {'id': 1, 'mediaApuracaoN': 3});

    // Tabela de Tipos de Combustível (V6 consolidada)
    await db.execute('''
      CREATE TABLE Combustiveis(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT UNIQUE
      )
    ''');

    // Tabela de Relação VeículoCombustivel (V6 consolidada)
    await db.execute('''
      CREATE TABLE VeiculoCombustivel(
        veiculoId INTEGER,
        combustivelId INTEGER,
        PRIMARY KEY (veiculoId, combustivelId)
      )
    ''');

    // O construtor do CombustivelRepository agora recebe o banco 'db'
    // Como ele não foi feito para receber 'db', vamos chamar a inicialização diretamente aqui:
    final List<String> defaultCombustiveis = [
      'Etanol',
      'Gasolina',
      'Diesel',
      'GNV',
    ];
    for (var nome in defaultCombustiveis) {
      await db.insert('Combustiveis', {'nome': nome});
    }

    debugPrint(
      "Database Versão 1 Criada: Todas as tabelas e colunas consolidadas.",
    );
  }

  // ----------------------------------------------------
  // 4. onUPGRADE (SISTEMA DE MIGRATE VAZIO)
  // ----------------------------------------------------
  // Mantemos o método, mas ele não contém mais as migrações antigas.
  // Qualquer alteração futura começará aqui (if oldVersion < 2, etc.)
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("Migrating DB from version $oldVersion to $newVersion...");

    // MIGRATE para a Versão 2: Adiciona o campo do último tanque cheio
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE Configuracoes ADD COLUMN encheuTanqueUltimoAbastecimento INTEGER DEFAULT 0;',
      );
      debugPrint(
        "Migrate v2: Adicionada coluna 'encheuTanqueUltimoAbastecimento' em Configuracoes.",
      );
    }
    debugPrint("Migração concluída. Versão atual: $newVersion");
  }
}
