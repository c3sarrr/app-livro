// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banco.dart';

// ignore_for_file: type=lint
class $UserBooksTable extends UserBooks
    with TableInfo<$UserBooksTable, LivroLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editionIdMeta = const VerificationMeta(
    'editionId',
  );
  @override
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
    'edition_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorDisplayMeta = const VerificationMeta(
    'authorDisplay',
  );
  @override
  late final GeneratedColumn<String> authorDisplay = GeneratedColumn<String>(
    'author_display',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentSha256Meta = const VerificationMeta(
    'contentSha256',
  );
  @override
  late final GeneratedColumn<String> contentSha256 = GeneratedColumn<String>(
    'content_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileBytesMeta = const VerificationMeta(
    'fileBytes',
  );
  @override
  late final GeneratedColumn<int> fileBytes = GeneratedColumn<int>(
    'file_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storageObjectPathMeta = const VerificationMeta(
    'storageObjectPath',
  );
  @override
  late final GeneratedColumn<String> storageObjectPath =
      GeneratedColumn<String>(
        'storage_object_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _refPagesTotalMeta = const VerificationMeta(
    'refPagesTotal',
  );
  @override
  late final GeneratedColumn<int> refPagesTotal = GeneratedColumn<int>(
    'ref_pages_total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refPageVersionMeta = const VerificationMeta(
    'refPageVersion',
  );
  @override
  late final GeneratedColumn<int> refPageVersion = GeneratedColumn<int>(
    'ref_page_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chaptersTotalMeta = const VerificationMeta(
    'chaptersTotal',
  );
  @override
  late final GeneratedColumn<int> chaptersTotal = GeneratedColumn<int>(
    'chapters_total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverRefMeta = const VerificationMeta(
    'coverRef',
  );
  @override
  late final GeneratedColumn<String> coverRef = GeneratedColumn<String>(
    'cover_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<String> addedAt = GeneratedColumn<String>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<String> startedAt = GeneratedColumn<String>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<String> finishedAt = GeneratedColumn<String>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<String> lastOpenedAt = GeneratedColumn<String>(
    'last_opened_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionHlcMeta = const VerificationMeta(
    'versionHlc',
  );
  @override
  late final GeneratedColumn<String> versionHlc = GeneratedColumn<String>(
    'version_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extrasMeta = const VerificationMeta('extras');
  @override
  late final GeneratedColumn<String> extras = GeneratedColumn<String>(
    '_extras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    editionId,
    title,
    authorDisplay,
    format,
    status,
    contentSha256,
    fileBytes,
    storageObjectPath,
    refPagesTotal,
    refPageVersion,
    chaptersTotal,
    coverRef,
    rating,
    addedAt,
    startedAt,
    finishedAt,
    lastOpenedAt,
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<LivroLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('edition_id')) {
      context.handle(
        _editionIdMeta,
        editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author_display')) {
      context.handle(
        _authorDisplayMeta,
        authorDisplay.isAcceptableOrUnknown(
          data['author_display']!,
          _authorDisplayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_authorDisplayMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('content_sha256')) {
      context.handle(
        _contentSha256Meta,
        contentSha256.isAcceptableOrUnknown(
          data['content_sha256']!,
          _contentSha256Meta,
        ),
      );
    }
    if (data.containsKey('file_bytes')) {
      context.handle(
        _fileBytesMeta,
        fileBytes.isAcceptableOrUnknown(data['file_bytes']!, _fileBytesMeta),
      );
    }
    if (data.containsKey('storage_object_path')) {
      context.handle(
        _storageObjectPathMeta,
        storageObjectPath.isAcceptableOrUnknown(
          data['storage_object_path']!,
          _storageObjectPathMeta,
        ),
      );
    }
    if (data.containsKey('ref_pages_total')) {
      context.handle(
        _refPagesTotalMeta,
        refPagesTotal.isAcceptableOrUnknown(
          data['ref_pages_total']!,
          _refPagesTotalMeta,
        ),
      );
    }
    if (data.containsKey('ref_page_version')) {
      context.handle(
        _refPageVersionMeta,
        refPageVersion.isAcceptableOrUnknown(
          data['ref_page_version']!,
          _refPageVersionMeta,
        ),
      );
    }
    if (data.containsKey('chapters_total')) {
      context.handle(
        _chaptersTotalMeta,
        chaptersTotal.isAcceptableOrUnknown(
          data['chapters_total']!,
          _chaptersTotalMeta,
        ),
      );
    }
    if (data.containsKey('cover_ref')) {
      context.handle(
        _coverRefMeta,
        coverRef.isAcceptableOrUnknown(data['cover_ref']!, _coverRefMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version_hlc')) {
      context.handle(
        _versionHlcMeta,
        versionHlc.isAcceptableOrUnknown(data['version_hlc']!, _versionHlcMeta),
      );
    } else if (isInserting) {
      context.missing(_versionHlcMeta);
    }
    if (data.containsKey('_extras')) {
      context.handle(
        _extrasMeta,
        extras.isAcceptableOrUnknown(data['_extras']!, _extrasMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LivroLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LivroLinha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      editionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edition_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      authorDisplay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_display'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      contentSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_sha256'],
      ),
      fileBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_bytes'],
      ),
      storageObjectPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_object_path'],
      ),
      refPagesTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ref_pages_total'],
      ),
      refPageVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ref_page_version'],
      ),
      chaptersTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapters_total'],
      ),
      coverRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_ref'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}added_at'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_at'],
      ),
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finished_at'],
      ),
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_opened_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      versionHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_hlc'],
      )!,
      extras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}_extras'],
      ),
    );
  }

  @override
  $UserBooksTable createAlias(String alias) {
    return $UserBooksTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class LivroLinha extends DataClass implements Insertable<LivroLinha> {
  final String id;
  final String userId;
  final String? editionId;
  final String title;
  final String authorDisplay;
  final String format;
  final String status;
  final String? contentSha256;
  final int? fileBytes;
  final String? storageObjectPath;
  final int? refPagesTotal;
  final int? refPageVersion;
  final int? chaptersTotal;
  final String? coverRef;
  final int? rating;
  final String addedAt;
  final String? startedAt;
  final String? finishedAt;
  final String? lastOpenedAt;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String versionHlc;

  /// Colunas que o servidor mandou e este app ainda não conhece (parâmetro "Rest" do put).
  final String? extras;
  const LivroLinha({
    required this.id,
    required this.userId,
    this.editionId,
    required this.title,
    required this.authorDisplay,
    required this.format,
    required this.status,
    this.contentSha256,
    this.fileBytes,
    this.storageObjectPath,
    this.refPagesTotal,
    this.refPageVersion,
    this.chaptersTotal,
    this.coverRef,
    this.rating,
    required this.addedAt,
    this.startedAt,
    this.finishedAt,
    this.lastOpenedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.versionHlc,
    this.extras,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || editionId != null) {
      map['edition_id'] = Variable<String>(editionId);
    }
    map['title'] = Variable<String>(title);
    map['author_display'] = Variable<String>(authorDisplay);
    map['format'] = Variable<String>(format);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || contentSha256 != null) {
      map['content_sha256'] = Variable<String>(contentSha256);
    }
    if (!nullToAbsent || fileBytes != null) {
      map['file_bytes'] = Variable<int>(fileBytes);
    }
    if (!nullToAbsent || storageObjectPath != null) {
      map['storage_object_path'] = Variable<String>(storageObjectPath);
    }
    if (!nullToAbsent || refPagesTotal != null) {
      map['ref_pages_total'] = Variable<int>(refPagesTotal);
    }
    if (!nullToAbsent || refPageVersion != null) {
      map['ref_page_version'] = Variable<int>(refPageVersion);
    }
    if (!nullToAbsent || chaptersTotal != null) {
      map['chapters_total'] = Variable<int>(chaptersTotal);
    }
    if (!nullToAbsent || coverRef != null) {
      map['cover_ref'] = Variable<String>(coverRef);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    map['added_at'] = Variable<String>(addedAt);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<String>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<String>(finishedAt);
    }
    if (!nullToAbsent || lastOpenedAt != null) {
      map['last_opened_at'] = Variable<String>(lastOpenedAt);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version_hlc'] = Variable<String>(versionHlc);
    if (!nullToAbsent || extras != null) {
      map['_extras'] = Variable<String>(extras);
    }
    return map;
  }

  UserBooksCompanion toCompanion(bool nullToAbsent) {
    return UserBooksCompanion(
      id: Value(id),
      userId: Value(userId),
      editionId: editionId == null && nullToAbsent
          ? const Value.absent()
          : Value(editionId),
      title: Value(title),
      authorDisplay: Value(authorDisplay),
      format: Value(format),
      status: Value(status),
      contentSha256: contentSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(contentSha256),
      fileBytes: fileBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(fileBytes),
      storageObjectPath: storageObjectPath == null && nullToAbsent
          ? const Value.absent()
          : Value(storageObjectPath),
      refPagesTotal: refPagesTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(refPagesTotal),
      refPageVersion: refPageVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(refPageVersion),
      chaptersTotal: chaptersTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(chaptersTotal),
      coverRef: coverRef == null && nullToAbsent
          ? const Value.absent()
          : Value(coverRef),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      addedAt: Value(addedAt),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      lastOpenedAt: lastOpenedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      versionHlc: Value(versionHlc),
      extras: extras == null && nullToAbsent
          ? const Value.absent()
          : Value(extras),
    );
  }

  factory LivroLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LivroLinha(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      editionId: serializer.fromJson<String?>(json['editionId']),
      title: serializer.fromJson<String>(json['title']),
      authorDisplay: serializer.fromJson<String>(json['authorDisplay']),
      format: serializer.fromJson<String>(json['format']),
      status: serializer.fromJson<String>(json['status']),
      contentSha256: serializer.fromJson<String?>(json['contentSha256']),
      fileBytes: serializer.fromJson<int?>(json['fileBytes']),
      storageObjectPath: serializer.fromJson<String?>(
        json['storageObjectPath'],
      ),
      refPagesTotal: serializer.fromJson<int?>(json['refPagesTotal']),
      refPageVersion: serializer.fromJson<int?>(json['refPageVersion']),
      chaptersTotal: serializer.fromJson<int?>(json['chaptersTotal']),
      coverRef: serializer.fromJson<String?>(json['coverRef']),
      rating: serializer.fromJson<int?>(json['rating']),
      addedAt: serializer.fromJson<String>(json['addedAt']),
      startedAt: serializer.fromJson<String?>(json['startedAt']),
      finishedAt: serializer.fromJson<String?>(json['finishedAt']),
      lastOpenedAt: serializer.fromJson<String?>(json['lastOpenedAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      versionHlc: serializer.fromJson<String>(json['versionHlc']),
      extras: serializer.fromJson<String?>(json['extras']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'editionId': serializer.toJson<String?>(editionId),
      'title': serializer.toJson<String>(title),
      'authorDisplay': serializer.toJson<String>(authorDisplay),
      'format': serializer.toJson<String>(format),
      'status': serializer.toJson<String>(status),
      'contentSha256': serializer.toJson<String?>(contentSha256),
      'fileBytes': serializer.toJson<int?>(fileBytes),
      'storageObjectPath': serializer.toJson<String?>(storageObjectPath),
      'refPagesTotal': serializer.toJson<int?>(refPagesTotal),
      'refPageVersion': serializer.toJson<int?>(refPageVersion),
      'chaptersTotal': serializer.toJson<int?>(chaptersTotal),
      'coverRef': serializer.toJson<String?>(coverRef),
      'rating': serializer.toJson<int?>(rating),
      'addedAt': serializer.toJson<String>(addedAt),
      'startedAt': serializer.toJson<String?>(startedAt),
      'finishedAt': serializer.toJson<String?>(finishedAt),
      'lastOpenedAt': serializer.toJson<String?>(lastOpenedAt),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'versionHlc': serializer.toJson<String>(versionHlc),
      'extras': serializer.toJson<String?>(extras),
    };
  }

  LivroLinha copyWith({
    String? id,
    String? userId,
    Value<String?> editionId = const Value.absent(),
    String? title,
    String? authorDisplay,
    String? format,
    String? status,
    Value<String?> contentSha256 = const Value.absent(),
    Value<int?> fileBytes = const Value.absent(),
    Value<String?> storageObjectPath = const Value.absent(),
    Value<int?> refPagesTotal = const Value.absent(),
    Value<int?> refPageVersion = const Value.absent(),
    Value<int?> chaptersTotal = const Value.absent(),
    Value<String?> coverRef = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    String? addedAt,
    Value<String?> startedAt = const Value.absent(),
    Value<String?> finishedAt = const Value.absent(),
    Value<String?> lastOpenedAt = const Value.absent(),
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? versionHlc,
    Value<String?> extras = const Value.absent(),
  }) => LivroLinha(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    editionId: editionId.present ? editionId.value : this.editionId,
    title: title ?? this.title,
    authorDisplay: authorDisplay ?? this.authorDisplay,
    format: format ?? this.format,
    status: status ?? this.status,
    contentSha256: contentSha256.present
        ? contentSha256.value
        : this.contentSha256,
    fileBytes: fileBytes.present ? fileBytes.value : this.fileBytes,
    storageObjectPath: storageObjectPath.present
        ? storageObjectPath.value
        : this.storageObjectPath,
    refPagesTotal: refPagesTotal.present
        ? refPagesTotal.value
        : this.refPagesTotal,
    refPageVersion: refPageVersion.present
        ? refPageVersion.value
        : this.refPageVersion,
    chaptersTotal: chaptersTotal.present
        ? chaptersTotal.value
        : this.chaptersTotal,
    coverRef: coverRef.present ? coverRef.value : this.coverRef,
    rating: rating.present ? rating.value : this.rating,
    addedAt: addedAt ?? this.addedAt,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    lastOpenedAt: lastOpenedAt.present ? lastOpenedAt.value : this.lastOpenedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    versionHlc: versionHlc ?? this.versionHlc,
    extras: extras.present ? extras.value : this.extras,
  );
  LivroLinha copyWithCompanion(UserBooksCompanion data) {
    return LivroLinha(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      title: data.title.present ? data.title.value : this.title,
      authorDisplay: data.authorDisplay.present
          ? data.authorDisplay.value
          : this.authorDisplay,
      format: data.format.present ? data.format.value : this.format,
      status: data.status.present ? data.status.value : this.status,
      contentSha256: data.contentSha256.present
          ? data.contentSha256.value
          : this.contentSha256,
      fileBytes: data.fileBytes.present ? data.fileBytes.value : this.fileBytes,
      storageObjectPath: data.storageObjectPath.present
          ? data.storageObjectPath.value
          : this.storageObjectPath,
      refPagesTotal: data.refPagesTotal.present
          ? data.refPagesTotal.value
          : this.refPagesTotal,
      refPageVersion: data.refPageVersion.present
          ? data.refPageVersion.value
          : this.refPageVersion,
      chaptersTotal: data.chaptersTotal.present
          ? data.chaptersTotal.value
          : this.chaptersTotal,
      coverRef: data.coverRef.present ? data.coverRef.value : this.coverRef,
      rating: data.rating.present ? data.rating.value : this.rating,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      versionHlc: data.versionHlc.present
          ? data.versionHlc.value
          : this.versionHlc,
      extras: data.extras.present ? data.extras.value : this.extras,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LivroLinha(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('editionId: $editionId, ')
          ..write('title: $title, ')
          ..write('authorDisplay: $authorDisplay, ')
          ..write('format: $format, ')
          ..write('status: $status, ')
          ..write('contentSha256: $contentSha256, ')
          ..write('fileBytes: $fileBytes, ')
          ..write('storageObjectPath: $storageObjectPath, ')
          ..write('refPagesTotal: $refPagesTotal, ')
          ..write('refPageVersion: $refPageVersion, ')
          ..write('chaptersTotal: $chaptersTotal, ')
          ..write('coverRef: $coverRef, ')
          ..write('rating: $rating, ')
          ..write('addedAt: $addedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    editionId,
    title,
    authorDisplay,
    format,
    status,
    contentSha256,
    fileBytes,
    storageObjectPath,
    refPagesTotal,
    refPageVersion,
    chaptersTotal,
    coverRef,
    rating,
    addedAt,
    startedAt,
    finishedAt,
    lastOpenedAt,
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LivroLinha &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.editionId == this.editionId &&
          other.title == this.title &&
          other.authorDisplay == this.authorDisplay &&
          other.format == this.format &&
          other.status == this.status &&
          other.contentSha256 == this.contentSha256 &&
          other.fileBytes == this.fileBytes &&
          other.storageObjectPath == this.storageObjectPath &&
          other.refPagesTotal == this.refPagesTotal &&
          other.refPageVersion == this.refPageVersion &&
          other.chaptersTotal == this.chaptersTotal &&
          other.coverRef == this.coverRef &&
          other.rating == this.rating &&
          other.addedAt == this.addedAt &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.lastOpenedAt == this.lastOpenedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.versionHlc == this.versionHlc &&
          other.extras == this.extras);
}

class UserBooksCompanion extends UpdateCompanion<LivroLinha> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> editionId;
  final Value<String> title;
  final Value<String> authorDisplay;
  final Value<String> format;
  final Value<String> status;
  final Value<String?> contentSha256;
  final Value<int?> fileBytes;
  final Value<String?> storageObjectPath;
  final Value<int?> refPagesTotal;
  final Value<int?> refPageVersion;
  final Value<int?> chaptersTotal;
  final Value<String?> coverRef;
  final Value<int?> rating;
  final Value<String> addedAt;
  final Value<String?> startedAt;
  final Value<String?> finishedAt;
  final Value<String?> lastOpenedAt;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> versionHlc;
  final Value<String?> extras;
  final Value<int> rowid;
  const UserBooksCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.editionId = const Value.absent(),
    this.title = const Value.absent(),
    this.authorDisplay = const Value.absent(),
    this.format = const Value.absent(),
    this.status = const Value.absent(),
    this.contentSha256 = const Value.absent(),
    this.fileBytes = const Value.absent(),
    this.storageObjectPath = const Value.absent(),
    this.refPagesTotal = const Value.absent(),
    this.refPageVersion = const Value.absent(),
    this.chaptersTotal = const Value.absent(),
    this.coverRef = const Value.absent(),
    this.rating = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.versionHlc = const Value.absent(),
    this.extras = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserBooksCompanion.insert({
    required String id,
    required String userId,
    this.editionId = const Value.absent(),
    required String title,
    required String authorDisplay,
    required String format,
    required String status,
    this.contentSha256 = const Value.absent(),
    this.fileBytes = const Value.absent(),
    this.storageObjectPath = const Value.absent(),
    this.refPagesTotal = const Value.absent(),
    this.refPageVersion = const Value.absent(),
    this.chaptersTotal = const Value.absent(),
    this.coverRef = const Value.absent(),
    this.rating = const Value.absent(),
    required String addedAt,
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String versionHlc,
    this.extras = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       authorDisplay = Value(authorDisplay),
       format = Value(format),
       status = Value(status),
       addedAt = Value(addedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       versionHlc = Value(versionHlc);
  static Insertable<LivroLinha> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? editionId,
    Expression<String>? title,
    Expression<String>? authorDisplay,
    Expression<String>? format,
    Expression<String>? status,
    Expression<String>? contentSha256,
    Expression<int>? fileBytes,
    Expression<String>? storageObjectPath,
    Expression<int>? refPagesTotal,
    Expression<int>? refPageVersion,
    Expression<int>? chaptersTotal,
    Expression<String>? coverRef,
    Expression<int>? rating,
    Expression<String>? addedAt,
    Expression<String>? startedAt,
    Expression<String>? finishedAt,
    Expression<String>? lastOpenedAt,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? versionHlc,
    Expression<String>? extras,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (editionId != null) 'edition_id': editionId,
      if (title != null) 'title': title,
      if (authorDisplay != null) 'author_display': authorDisplay,
      if (format != null) 'format': format,
      if (status != null) 'status': status,
      if (contentSha256 != null) 'content_sha256': contentSha256,
      if (fileBytes != null) 'file_bytes': fileBytes,
      if (storageObjectPath != null) 'storage_object_path': storageObjectPath,
      if (refPagesTotal != null) 'ref_pages_total': refPagesTotal,
      if (refPageVersion != null) 'ref_page_version': refPageVersion,
      if (chaptersTotal != null) 'chapters_total': chaptersTotal,
      if (coverRef != null) 'cover_ref': coverRef,
      if (rating != null) 'rating': rating,
      if (addedAt != null) 'added_at': addedAt,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (versionHlc != null) 'version_hlc': versionHlc,
      if (extras != null) '_extras': extras,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserBooksCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? editionId,
    Value<String>? title,
    Value<String>? authorDisplay,
    Value<String>? format,
    Value<String>? status,
    Value<String?>? contentSha256,
    Value<int?>? fileBytes,
    Value<String?>? storageObjectPath,
    Value<int?>? refPagesTotal,
    Value<int?>? refPageVersion,
    Value<int?>? chaptersTotal,
    Value<String?>? coverRef,
    Value<int?>? rating,
    Value<String>? addedAt,
    Value<String?>? startedAt,
    Value<String?>? finishedAt,
    Value<String?>? lastOpenedAt,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? versionHlc,
    Value<String?>? extras,
    Value<int>? rowid,
  }) {
    return UserBooksCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      editionId: editionId ?? this.editionId,
      title: title ?? this.title,
      authorDisplay: authorDisplay ?? this.authorDisplay,
      format: format ?? this.format,
      status: status ?? this.status,
      contentSha256: contentSha256 ?? this.contentSha256,
      fileBytes: fileBytes ?? this.fileBytes,
      storageObjectPath: storageObjectPath ?? this.storageObjectPath,
      refPagesTotal: refPagesTotal ?? this.refPagesTotal,
      refPageVersion: refPageVersion ?? this.refPageVersion,
      chaptersTotal: chaptersTotal ?? this.chaptersTotal,
      coverRef: coverRef ?? this.coverRef,
      rating: rating ?? this.rating,
      addedAt: addedAt ?? this.addedAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      versionHlc: versionHlc ?? this.versionHlc,
      extras: extras ?? this.extras,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (authorDisplay.present) {
      map['author_display'] = Variable<String>(authorDisplay.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (contentSha256.present) {
      map['content_sha256'] = Variable<String>(contentSha256.value);
    }
    if (fileBytes.present) {
      map['file_bytes'] = Variable<int>(fileBytes.value);
    }
    if (storageObjectPath.present) {
      map['storage_object_path'] = Variable<String>(storageObjectPath.value);
    }
    if (refPagesTotal.present) {
      map['ref_pages_total'] = Variable<int>(refPagesTotal.value);
    }
    if (refPageVersion.present) {
      map['ref_page_version'] = Variable<int>(refPageVersion.value);
    }
    if (chaptersTotal.present) {
      map['chapters_total'] = Variable<int>(chaptersTotal.value);
    }
    if (coverRef.present) {
      map['cover_ref'] = Variable<String>(coverRef.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<String>(addedAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<String>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<String>(finishedAt.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<String>(lastOpenedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (versionHlc.present) {
      map['version_hlc'] = Variable<String>(versionHlc.value);
    }
    if (extras.present) {
      map['_extras'] = Variable<String>(extras.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserBooksCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('editionId: $editionId, ')
          ..write('title: $title, ')
          ..write('authorDisplay: $authorDisplay, ')
          ..write('format: $format, ')
          ..write('status: $status, ')
          ..write('contentSha256: $contentSha256, ')
          ..write('fileBytes: $fileBytes, ')
          ..write('storageObjectPath: $storageObjectPath, ')
          ..write('refPagesTotal: $refPagesTotal, ')
          ..write('refPageVersion: $refPageVersion, ')
          ..write('chaptersTotal: $chaptersTotal, ')
          ..write('coverRef: $coverRef, ')
          ..write('rating: $rating, ')
          ..write('addedAt: $addedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnnotationsTable extends Annotations
    with TableInfo<$AnnotationsTable, AnotacaoLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnnotationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userBookIdMeta = const VerificationMeta(
    'userBookId',
  );
  @override
  late final GeneratedColumn<String> userBookId = GeneratedColumn<String>(
    'user_book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anchorMeta = const VerificationMeta('anchor');
  @override
  late final GeneratedColumn<String> anchor = GeneratedColumn<String>(
    'anchor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refPageMeta = const VerificationMeta(
    'refPage',
  );
  @override
  late final GeneratedColumn<int> refPage = GeneratedColumn<int>(
    'ref_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _styleMeta = const VerificationMeta('style');
  @override
  late final GeneratedColumn<String> style = GeneratedColumn<String>(
    'style',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fillHeightMeta = const VerificationMeta(
    'fillHeight',
  );
  @override
  late final GeneratedColumn<String> fillHeight = GeneratedColumn<String>(
    'fill_height',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteTextMeta = const VerificationMeta(
    'noteText',
  );
  @override
  late final GeneratedColumn<String> noteText = GeneratedColumn<String>(
    'note_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inkLayerIdMeta = const VerificationMeta(
    'inkLayerId',
  );
  @override
  late final GeneratedColumn<String> inkLayerId = GeneratedColumn<String>(
    'ink_layer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sharedClubPostIdMeta = const VerificationMeta(
    'sharedClubPostId',
  );
  @override
  late final GeneratedColumn<String> sharedClubPostId = GeneratedColumn<String>(
    'shared_club_post_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionHlcMeta = const VerificationMeta(
    'versionHlc',
  );
  @override
  late final GeneratedColumn<String> versionHlc = GeneratedColumn<String>(
    'version_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extrasMeta = const VerificationMeta('extras');
  @override
  late final GeneratedColumn<String> extras = GeneratedColumn<String>(
    '_extras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    userBookId,
    kind,
    parentId,
    groupId,
    source,
    anchor,
    refPage,
    chapterIndex,
    color,
    style,
    fillHeight,
    noteText,
    inkLayerId,
    sharedClubPostId,
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'annotations';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnotacaoLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('user_book_id')) {
      context.handle(
        _userBookIdMeta,
        userBookId.isAcceptableOrUnknown(
          data['user_book_id']!,
          _userBookIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userBookIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('anchor')) {
      context.handle(
        _anchorMeta,
        anchor.isAcceptableOrUnknown(data['anchor']!, _anchorMeta),
      );
    } else if (isInserting) {
      context.missing(_anchorMeta);
    }
    if (data.containsKey('ref_page')) {
      context.handle(
        _refPageMeta,
        refPage.isAcceptableOrUnknown(data['ref_page']!, _refPageMeta),
      );
    } else if (isInserting) {
      context.missing(_refPageMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('style')) {
      context.handle(
        _styleMeta,
        style.isAcceptableOrUnknown(data['style']!, _styleMeta),
      );
    }
    if (data.containsKey('fill_height')) {
      context.handle(
        _fillHeightMeta,
        fillHeight.isAcceptableOrUnknown(data['fill_height']!, _fillHeightMeta),
      );
    }
    if (data.containsKey('note_text')) {
      context.handle(
        _noteTextMeta,
        noteText.isAcceptableOrUnknown(data['note_text']!, _noteTextMeta),
      );
    }
    if (data.containsKey('ink_layer_id')) {
      context.handle(
        _inkLayerIdMeta,
        inkLayerId.isAcceptableOrUnknown(
          data['ink_layer_id']!,
          _inkLayerIdMeta,
        ),
      );
    }
    if (data.containsKey('shared_club_post_id')) {
      context.handle(
        _sharedClubPostIdMeta,
        sharedClubPostId.isAcceptableOrUnknown(
          data['shared_club_post_id']!,
          _sharedClubPostIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version_hlc')) {
      context.handle(
        _versionHlcMeta,
        versionHlc.isAcceptableOrUnknown(data['version_hlc']!, _versionHlcMeta),
      );
    } else if (isInserting) {
      context.missing(_versionHlcMeta);
    }
    if (data.containsKey('_extras')) {
      context.handle(
        _extrasMeta,
        extras.isAcceptableOrUnknown(data['_extras']!, _extrasMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnotacaoLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnotacaoLinha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      userBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_book_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      anchor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anchor'],
      )!,
      refPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ref_page'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      style: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style'],
      ),
      fillHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fill_height'],
      ),
      noteText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_text'],
      ),
      inkLayerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ink_layer_id'],
      ),
      sharedClubPostId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shared_club_post_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      versionHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_hlc'],
      )!,
      extras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}_extras'],
      ),
    );
  }

  @override
  $AnnotationsTable createAlias(String alias) {
    return $AnnotationsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class AnotacaoLinha extends DataClass implements Insertable<AnotacaoLinha> {
  final String id;
  final String userId;
  final String userBookId;
  final String kind;
  final String? parentId;
  final String groupId;
  final String source;
  final String anchor;
  final int refPage;
  final int chapterIndex;
  final String? color;
  final String? style;
  final String? fillHeight;
  final String? noteText;
  final String? inkLayerId;
  final String? sharedClubPostId;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String versionHlc;

  /// Colunas que o servidor mandou e este app ainda não conhece (parâmetro "Rest" do put).
  final String? extras;
  const AnotacaoLinha({
    required this.id,
    required this.userId,
    required this.userBookId,
    required this.kind,
    this.parentId,
    required this.groupId,
    required this.source,
    required this.anchor,
    required this.refPage,
    required this.chapterIndex,
    this.color,
    this.style,
    this.fillHeight,
    this.noteText,
    this.inkLayerId,
    this.sharedClubPostId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.versionHlc,
    this.extras,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['user_book_id'] = Variable<String>(userBookId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['group_id'] = Variable<String>(groupId);
    map['source'] = Variable<String>(source);
    map['anchor'] = Variable<String>(anchor);
    map['ref_page'] = Variable<int>(refPage);
    map['chapter_index'] = Variable<int>(chapterIndex);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || style != null) {
      map['style'] = Variable<String>(style);
    }
    if (!nullToAbsent || fillHeight != null) {
      map['fill_height'] = Variable<String>(fillHeight);
    }
    if (!nullToAbsent || noteText != null) {
      map['note_text'] = Variable<String>(noteText);
    }
    if (!nullToAbsent || inkLayerId != null) {
      map['ink_layer_id'] = Variable<String>(inkLayerId);
    }
    if (!nullToAbsent || sharedClubPostId != null) {
      map['shared_club_post_id'] = Variable<String>(sharedClubPostId);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version_hlc'] = Variable<String>(versionHlc);
    if (!nullToAbsent || extras != null) {
      map['_extras'] = Variable<String>(extras);
    }
    return map;
  }

  AnnotationsCompanion toCompanion(bool nullToAbsent) {
    return AnnotationsCompanion(
      id: Value(id),
      userId: Value(userId),
      userBookId: Value(userBookId),
      kind: Value(kind),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      groupId: Value(groupId),
      source: Value(source),
      anchor: Value(anchor),
      refPage: Value(refPage),
      chapterIndex: Value(chapterIndex),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      style: style == null && nullToAbsent
          ? const Value.absent()
          : Value(style),
      fillHeight: fillHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(fillHeight),
      noteText: noteText == null && nullToAbsent
          ? const Value.absent()
          : Value(noteText),
      inkLayerId: inkLayerId == null && nullToAbsent
          ? const Value.absent()
          : Value(inkLayerId),
      sharedClubPostId: sharedClubPostId == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedClubPostId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      versionHlc: Value(versionHlc),
      extras: extras == null && nullToAbsent
          ? const Value.absent()
          : Value(extras),
    );
  }

  factory AnotacaoLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnotacaoLinha(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      userBookId: serializer.fromJson<String>(json['userBookId']),
      kind: serializer.fromJson<String>(json['kind']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      groupId: serializer.fromJson<String>(json['groupId']),
      source: serializer.fromJson<String>(json['source']),
      anchor: serializer.fromJson<String>(json['anchor']),
      refPage: serializer.fromJson<int>(json['refPage']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      color: serializer.fromJson<String?>(json['color']),
      style: serializer.fromJson<String?>(json['style']),
      fillHeight: serializer.fromJson<String?>(json['fillHeight']),
      noteText: serializer.fromJson<String?>(json['noteText']),
      inkLayerId: serializer.fromJson<String?>(json['inkLayerId']),
      sharedClubPostId: serializer.fromJson<String?>(json['sharedClubPostId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      versionHlc: serializer.fromJson<String>(json['versionHlc']),
      extras: serializer.fromJson<String?>(json['extras']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'userBookId': serializer.toJson<String>(userBookId),
      'kind': serializer.toJson<String>(kind),
      'parentId': serializer.toJson<String?>(parentId),
      'groupId': serializer.toJson<String>(groupId),
      'source': serializer.toJson<String>(source),
      'anchor': serializer.toJson<String>(anchor),
      'refPage': serializer.toJson<int>(refPage),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'color': serializer.toJson<String?>(color),
      'style': serializer.toJson<String?>(style),
      'fillHeight': serializer.toJson<String?>(fillHeight),
      'noteText': serializer.toJson<String?>(noteText),
      'inkLayerId': serializer.toJson<String?>(inkLayerId),
      'sharedClubPostId': serializer.toJson<String?>(sharedClubPostId),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'versionHlc': serializer.toJson<String>(versionHlc),
      'extras': serializer.toJson<String?>(extras),
    };
  }

  AnotacaoLinha copyWith({
    String? id,
    String? userId,
    String? userBookId,
    String? kind,
    Value<String?> parentId = const Value.absent(),
    String? groupId,
    String? source,
    String? anchor,
    int? refPage,
    int? chapterIndex,
    Value<String?> color = const Value.absent(),
    Value<String?> style = const Value.absent(),
    Value<String?> fillHeight = const Value.absent(),
    Value<String?> noteText = const Value.absent(),
    Value<String?> inkLayerId = const Value.absent(),
    Value<String?> sharedClubPostId = const Value.absent(),
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? versionHlc,
    Value<String?> extras = const Value.absent(),
  }) => AnotacaoLinha(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    userBookId: userBookId ?? this.userBookId,
    kind: kind ?? this.kind,
    parentId: parentId.present ? parentId.value : this.parentId,
    groupId: groupId ?? this.groupId,
    source: source ?? this.source,
    anchor: anchor ?? this.anchor,
    refPage: refPage ?? this.refPage,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    color: color.present ? color.value : this.color,
    style: style.present ? style.value : this.style,
    fillHeight: fillHeight.present ? fillHeight.value : this.fillHeight,
    noteText: noteText.present ? noteText.value : this.noteText,
    inkLayerId: inkLayerId.present ? inkLayerId.value : this.inkLayerId,
    sharedClubPostId: sharedClubPostId.present
        ? sharedClubPostId.value
        : this.sharedClubPostId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    versionHlc: versionHlc ?? this.versionHlc,
    extras: extras.present ? extras.value : this.extras,
  );
  AnotacaoLinha copyWithCompanion(AnnotationsCompanion data) {
    return AnotacaoLinha(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      userBookId: data.userBookId.present
          ? data.userBookId.value
          : this.userBookId,
      kind: data.kind.present ? data.kind.value : this.kind,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      source: data.source.present ? data.source.value : this.source,
      anchor: data.anchor.present ? data.anchor.value : this.anchor,
      refPage: data.refPage.present ? data.refPage.value : this.refPage,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      color: data.color.present ? data.color.value : this.color,
      style: data.style.present ? data.style.value : this.style,
      fillHeight: data.fillHeight.present
          ? data.fillHeight.value
          : this.fillHeight,
      noteText: data.noteText.present ? data.noteText.value : this.noteText,
      inkLayerId: data.inkLayerId.present
          ? data.inkLayerId.value
          : this.inkLayerId,
      sharedClubPostId: data.sharedClubPostId.present
          ? data.sharedClubPostId.value
          : this.sharedClubPostId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      versionHlc: data.versionHlc.present
          ? data.versionHlc.value
          : this.versionHlc,
      extras: data.extras.present ? data.extras.value : this.extras,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnotacaoLinha(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userBookId: $userBookId, ')
          ..write('kind: $kind, ')
          ..write('parentId: $parentId, ')
          ..write('groupId: $groupId, ')
          ..write('source: $source, ')
          ..write('anchor: $anchor, ')
          ..write('refPage: $refPage, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('color: $color, ')
          ..write('style: $style, ')
          ..write('fillHeight: $fillHeight, ')
          ..write('noteText: $noteText, ')
          ..write('inkLayerId: $inkLayerId, ')
          ..write('sharedClubPostId: $sharedClubPostId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    userBookId,
    kind,
    parentId,
    groupId,
    source,
    anchor,
    refPage,
    chapterIndex,
    color,
    style,
    fillHeight,
    noteText,
    inkLayerId,
    sharedClubPostId,
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnotacaoLinha &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.userBookId == this.userBookId &&
          other.kind == this.kind &&
          other.parentId == this.parentId &&
          other.groupId == this.groupId &&
          other.source == this.source &&
          other.anchor == this.anchor &&
          other.refPage == this.refPage &&
          other.chapterIndex == this.chapterIndex &&
          other.color == this.color &&
          other.style == this.style &&
          other.fillHeight == this.fillHeight &&
          other.noteText == this.noteText &&
          other.inkLayerId == this.inkLayerId &&
          other.sharedClubPostId == this.sharedClubPostId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.versionHlc == this.versionHlc &&
          other.extras == this.extras);
}

class AnnotationsCompanion extends UpdateCompanion<AnotacaoLinha> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> userBookId;
  final Value<String> kind;
  final Value<String?> parentId;
  final Value<String> groupId;
  final Value<String> source;
  final Value<String> anchor;
  final Value<int> refPage;
  final Value<int> chapterIndex;
  final Value<String?> color;
  final Value<String?> style;
  final Value<String?> fillHeight;
  final Value<String?> noteText;
  final Value<String?> inkLayerId;
  final Value<String?> sharedClubPostId;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> versionHlc;
  final Value<String?> extras;
  final Value<int> rowid;
  const AnnotationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.userBookId = const Value.absent(),
    this.kind = const Value.absent(),
    this.parentId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.source = const Value.absent(),
    this.anchor = const Value.absent(),
    this.refPage = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.color = const Value.absent(),
    this.style = const Value.absent(),
    this.fillHeight = const Value.absent(),
    this.noteText = const Value.absent(),
    this.inkLayerId = const Value.absent(),
    this.sharedClubPostId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.versionHlc = const Value.absent(),
    this.extras = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnnotationsCompanion.insert({
    required String id,
    required String userId,
    required String userBookId,
    required String kind,
    this.parentId = const Value.absent(),
    required String groupId,
    required String source,
    required String anchor,
    required int refPage,
    required int chapterIndex,
    this.color = const Value.absent(),
    this.style = const Value.absent(),
    this.fillHeight = const Value.absent(),
    this.noteText = const Value.absent(),
    this.inkLayerId = const Value.absent(),
    this.sharedClubPostId = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String versionHlc,
    this.extras = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       userBookId = Value(userBookId),
       kind = Value(kind),
       groupId = Value(groupId),
       source = Value(source),
       anchor = Value(anchor),
       refPage = Value(refPage),
       chapterIndex = Value(chapterIndex),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       versionHlc = Value(versionHlc);
  static Insertable<AnotacaoLinha> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? userBookId,
    Expression<String>? kind,
    Expression<String>? parentId,
    Expression<String>? groupId,
    Expression<String>? source,
    Expression<String>? anchor,
    Expression<int>? refPage,
    Expression<int>? chapterIndex,
    Expression<String>? color,
    Expression<String>? style,
    Expression<String>? fillHeight,
    Expression<String>? noteText,
    Expression<String>? inkLayerId,
    Expression<String>? sharedClubPostId,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? versionHlc,
    Expression<String>? extras,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (userBookId != null) 'user_book_id': userBookId,
      if (kind != null) 'kind': kind,
      if (parentId != null) 'parent_id': parentId,
      if (groupId != null) 'group_id': groupId,
      if (source != null) 'source': source,
      if (anchor != null) 'anchor': anchor,
      if (refPage != null) 'ref_page': refPage,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (color != null) 'color': color,
      if (style != null) 'style': style,
      if (fillHeight != null) 'fill_height': fillHeight,
      if (noteText != null) 'note_text': noteText,
      if (inkLayerId != null) 'ink_layer_id': inkLayerId,
      if (sharedClubPostId != null) 'shared_club_post_id': sharedClubPostId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (versionHlc != null) 'version_hlc': versionHlc,
      if (extras != null) '_extras': extras,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnnotationsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? userBookId,
    Value<String>? kind,
    Value<String?>? parentId,
    Value<String>? groupId,
    Value<String>? source,
    Value<String>? anchor,
    Value<int>? refPage,
    Value<int>? chapterIndex,
    Value<String?>? color,
    Value<String?>? style,
    Value<String?>? fillHeight,
    Value<String?>? noteText,
    Value<String?>? inkLayerId,
    Value<String?>? sharedClubPostId,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? versionHlc,
    Value<String?>? extras,
    Value<int>? rowid,
  }) {
    return AnnotationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userBookId: userBookId ?? this.userBookId,
      kind: kind ?? this.kind,
      parentId: parentId ?? this.parentId,
      groupId: groupId ?? this.groupId,
      source: source ?? this.source,
      anchor: anchor ?? this.anchor,
      refPage: refPage ?? this.refPage,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      color: color ?? this.color,
      style: style ?? this.style,
      fillHeight: fillHeight ?? this.fillHeight,
      noteText: noteText ?? this.noteText,
      inkLayerId: inkLayerId ?? this.inkLayerId,
      sharedClubPostId: sharedClubPostId ?? this.sharedClubPostId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      versionHlc: versionHlc ?? this.versionHlc,
      extras: extras ?? this.extras,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (userBookId.present) {
      map['user_book_id'] = Variable<String>(userBookId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (anchor.present) {
      map['anchor'] = Variable<String>(anchor.value);
    }
    if (refPage.present) {
      map['ref_page'] = Variable<int>(refPage.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (style.present) {
      map['style'] = Variable<String>(style.value);
    }
    if (fillHeight.present) {
      map['fill_height'] = Variable<String>(fillHeight.value);
    }
    if (noteText.present) {
      map['note_text'] = Variable<String>(noteText.value);
    }
    if (inkLayerId.present) {
      map['ink_layer_id'] = Variable<String>(inkLayerId.value);
    }
    if (sharedClubPostId.present) {
      map['shared_club_post_id'] = Variable<String>(sharedClubPostId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (versionHlc.present) {
      map['version_hlc'] = Variable<String>(versionHlc.value);
    }
    if (extras.present) {
      map['_extras'] = Variable<String>(extras.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnnotationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userBookId: $userBookId, ')
          ..write('kind: $kind, ')
          ..write('parentId: $parentId, ')
          ..write('groupId: $groupId, ')
          ..write('source: $source, ')
          ..write('anchor: $anchor, ')
          ..write('refPage: $refPage, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('color: $color, ')
          ..write('style: $style, ')
          ..write('fillHeight: $fillHeight, ')
          ..write('noteText: $noteText, ')
          ..write('inkLayerId: $inkLayerId, ')
          ..write('sharedClubPostId: $sharedClubPostId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BancoSpike extends GeneratedDatabase {
  _$BancoSpike(QueryExecutor e) : super(e);
  $BancoSpikeManager get managers => $BancoSpikeManager(this);
  late final $UserBooksTable userBooks = $UserBooksTable(this);
  late final $AnnotationsTable annotations = $AnnotationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [userBooks, annotations];
}

typedef $$UserBooksTableCreateCompanionBuilder = UserBooksCompanion Function({
  required String id,
  required String userId,
  Value<String?> editionId,
  required String title,
  required String authorDisplay,
  required String format,
  required String status,
  Value<String?> contentSha256,
  Value<int?> fileBytes,
  Value<String?> storageObjectPath,
  Value<int?> refPagesTotal,
  Value<int?> refPageVersion,
  Value<int?> chaptersTotal,
  Value<String?> coverRef,
  Value<int?> rating,
  required String addedAt,
  Value<String?> startedAt,
  Value<String?> finishedAt,
  Value<String?> lastOpenedAt,
  required String createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  required String versionHlc,
  Value<String?> extras,
  Value<int> rowid,
});
typedef $$UserBooksTableUpdateCompanionBuilder = UserBooksCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> editionId,
  Value<String> title,
  Value<String> authorDisplay,
  Value<String> format,
  Value<String> status,
  Value<String?> contentSha256,
  Value<int?> fileBytes,
  Value<String?> storageObjectPath,
  Value<int?> refPagesTotal,
  Value<int?> refPageVersion,
  Value<int?> chaptersTotal,
  Value<String?> coverRef,
  Value<int?> rating,
  Value<String> addedAt,
  Value<String?> startedAt,
  Value<String?> finishedAt,
  Value<String?> lastOpenedAt,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String> versionHlc,
  Value<String?> extras,
  Value<int> rowid,
});

class $$UserBooksTableFilterComposer
    extends Composer<_$BancoSpike, $UserBooksTable> {
  $$UserBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get editionId => $composableBuilder(
    column: $table.editionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorDisplay => $composableBuilder(
    column: $table.authorDisplay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentSha256 => $composableBuilder(
    column: $table.contentSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileBytes => $composableBuilder(
    column: $table.fileBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageObjectPath => $composableBuilder(
    column: $table.storageObjectPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refPagesTotal => $composableBuilder(
    column: $table.refPagesTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refPageVersion => $composableBuilder(
    column: $table.refPageVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chaptersTotal => $composableBuilder(
    column: $table.chaptersTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverRef => $composableBuilder(
    column: $table.coverRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get versionHlc => $composableBuilder(
    column: $table.versionHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extras => $composableBuilder(
    column: $table.extras,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserBooksTableOrderingComposer
    extends Composer<_$BancoSpike, $UserBooksTable> {
  $$UserBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editionId => $composableBuilder(
    column: $table.editionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorDisplay => $composableBuilder(
    column: $table.authorDisplay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentSha256 => $composableBuilder(
    column: $table.contentSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileBytes => $composableBuilder(
    column: $table.fileBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageObjectPath => $composableBuilder(
    column: $table.storageObjectPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refPagesTotal => $composableBuilder(
    column: $table.refPagesTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refPageVersion => $composableBuilder(
    column: $table.refPageVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chaptersTotal => $composableBuilder(
    column: $table.chaptersTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverRef => $composableBuilder(
    column: $table.coverRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get versionHlc => $composableBuilder(
    column: $table.versionHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extras => $composableBuilder(
    column: $table.extras,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserBooksTableAnnotationComposer
    extends Composer<_$BancoSpike, $UserBooksTable> {
  $$UserBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get editionId =>
      $composableBuilder(column: $table.editionId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get authorDisplay => $composableBuilder(
    column: $table.authorDisplay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get contentSha256 => $composableBuilder(
    column: $table.contentSha256,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileBytes =>
      $composableBuilder(column: $table.fileBytes, builder: (column) => column);

  GeneratedColumn<String> get storageObjectPath => $composableBuilder(
    column: $table.storageObjectPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get refPagesTotal => $composableBuilder(
    column: $table.refPagesTotal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get refPageVersion => $composableBuilder(
    column: $table.refPageVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chaptersTotal => $composableBuilder(
    column: $table.chaptersTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverRef =>
      $composableBuilder(column: $table.coverRef, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get versionHlc => $composableBuilder(
    column: $table.versionHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extras =>
      $composableBuilder(column: $table.extras, builder: (column) => column);
}

class $$UserBooksTableTableManager
    extends
        RootTableManager<
          _$BancoSpike,
          $UserBooksTable,
          LivroLinha,
          $$UserBooksTableFilterComposer,
          $$UserBooksTableOrderingComposer,
          $$UserBooksTableAnnotationComposer,
          $$UserBooksTableCreateCompanionBuilder,
          $$UserBooksTableUpdateCompanionBuilder,
          (
            LivroLinha,
            BaseReferences<_$BancoSpike, $UserBooksTable, LivroLinha>,
          ),
          LivroLinha,
          PrefetchHooks Function()
        > {
  $$UserBooksTableTableManager(_$BancoSpike db, $UserBooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> editionId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> authorDisplay = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> contentSha256 = const Value.absent(),
                Value<int?> fileBytes = const Value.absent(),
                Value<String?> storageObjectPath = const Value.absent(),
                Value<int?> refPagesTotal = const Value.absent(),
                Value<int?> refPageVersion = const Value.absent(),
                Value<int?> chaptersTotal = const Value.absent(),
                Value<String?> coverRef = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String> addedAt = const Value.absent(),
                Value<String?> startedAt = const Value.absent(),
                Value<String?> finishedAt = const Value.absent(),
                Value<String?> lastOpenedAt = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> versionHlc = const Value.absent(),
                Value<String?> extras = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserBooksCompanion(
                id: id,
                userId: userId,
                editionId: editionId,
                title: title,
                authorDisplay: authorDisplay,
                format: format,
                status: status,
                contentSha256: contentSha256,
                fileBytes: fileBytes,
                storageObjectPath: storageObjectPath,
                refPagesTotal: refPagesTotal,
                refPageVersion: refPageVersion,
                chaptersTotal: chaptersTotal,
                coverRef: coverRef,
                rating: rating,
                addedAt: addedAt,
                startedAt: startedAt,
                finishedAt: finishedAt,
                lastOpenedAt: lastOpenedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                versionHlc: versionHlc,
                extras: extras,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> editionId = const Value.absent(),
                required String title,
                required String authorDisplay,
                required String format,
                required String status,
                Value<String?> contentSha256 = const Value.absent(),
                Value<int?> fileBytes = const Value.absent(),
                Value<String?> storageObjectPath = const Value.absent(),
                Value<int?> refPagesTotal = const Value.absent(),
                Value<int?> refPageVersion = const Value.absent(),
                Value<int?> chaptersTotal = const Value.absent(),
                Value<String?> coverRef = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                required String addedAt,
                Value<String?> startedAt = const Value.absent(),
                Value<String?> finishedAt = const Value.absent(),
                Value<String?> lastOpenedAt = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String versionHlc,
                Value<String?> extras = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserBooksCompanion.insert(
                id: id,
                userId: userId,
                editionId: editionId,
                title: title,
                authorDisplay: authorDisplay,
                format: format,
                status: status,
                contentSha256: contentSha256,
                fileBytes: fileBytes,
                storageObjectPath: storageObjectPath,
                refPagesTotal: refPagesTotal,
                refPageVersion: refPageVersion,
                chaptersTotal: chaptersTotal,
                coverRef: coverRef,
                rating: rating,
                addedAt: addedAt,
                startedAt: startedAt,
                finishedAt: finishedAt,
                lastOpenedAt: lastOpenedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                versionHlc: versionHlc,
                extras: extras,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserBooksTable, LivroLinha>(table),
                  BaseReferences<_$BancoSpike, $UserBooksTable, LivroLinha>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoSpike,
      $UserBooksTable,
      LivroLinha,
      $$UserBooksTableFilterComposer,
      $$UserBooksTableOrderingComposer,
      $$UserBooksTableAnnotationComposer,
      $$UserBooksTableCreateCompanionBuilder,
      $$UserBooksTableUpdateCompanionBuilder,
      (LivroLinha, BaseReferences<_$BancoSpike, $UserBooksTable, LivroLinha>),
      LivroLinha,
      PrefetchHooks Function()
    >;
typedef $$AnnotationsTableCreateCompanionBuilder =
    AnnotationsCompanion Function({
      required String id,
      required String userId,
      required String userBookId,
      required String kind,
      Value<String?> parentId,
      required String groupId,
      required String source,
      required String anchor,
      required int refPage,
      required int chapterIndex,
      Value<String?> color,
      Value<String?> style,
      Value<String?> fillHeight,
      Value<String?> noteText,
      Value<String?> inkLayerId,
      Value<String?> sharedClubPostId,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String versionHlc,
      Value<String?> extras,
      Value<int> rowid,
    });
typedef $$AnnotationsTableUpdateCompanionBuilder =
    AnnotationsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> userBookId,
      Value<String> kind,
      Value<String?> parentId,
      Value<String> groupId,
      Value<String> source,
      Value<String> anchor,
      Value<int> refPage,
      Value<int> chapterIndex,
      Value<String?> color,
      Value<String?> style,
      Value<String?> fillHeight,
      Value<String?> noteText,
      Value<String?> inkLayerId,
      Value<String?> sharedClubPostId,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> versionHlc,
      Value<String?> extras,
      Value<int> rowid,
    });

class $$AnnotationsTableFilterComposer
    extends Composer<_$BancoSpike, $AnnotationsTable> {
  $$AnnotationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userBookId => $composableBuilder(
    column: $table.userBookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anchor => $composableBuilder(
    column: $table.anchor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refPage => $composableBuilder(
    column: $table.refPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fillHeight => $composableBuilder(
    column: $table.fillHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inkLayerId => $composableBuilder(
    column: $table.inkLayerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sharedClubPostId => $composableBuilder(
    column: $table.sharedClubPostId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get versionHlc => $composableBuilder(
    column: $table.versionHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extras => $composableBuilder(
    column: $table.extras,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnnotationsTableOrderingComposer
    extends Composer<_$BancoSpike, $AnnotationsTable> {
  $$AnnotationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userBookId => $composableBuilder(
    column: $table.userBookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchor => $composableBuilder(
    column: $table.anchor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refPage => $composableBuilder(
    column: $table.refPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fillHeight => $composableBuilder(
    column: $table.fillHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inkLayerId => $composableBuilder(
    column: $table.inkLayerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sharedClubPostId => $composableBuilder(
    column: $table.sharedClubPostId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get versionHlc => $composableBuilder(
    column: $table.versionHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extras => $composableBuilder(
    column: $table.extras,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnnotationsTableAnnotationComposer
    extends Composer<_$BancoSpike, $AnnotationsTable> {
  $$AnnotationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get userBookId => $composableBuilder(
    column: $table.userBookId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get anchor =>
      $composableBuilder(column: $table.anchor, builder: (column) => column);

  GeneratedColumn<int> get refPage =>
      $composableBuilder(column: $table.refPage, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get style =>
      $composableBuilder(column: $table.style, builder: (column) => column);

  GeneratedColumn<String> get fillHeight => $composableBuilder(
    column: $table.fillHeight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get noteText =>
      $composableBuilder(column: $table.noteText, builder: (column) => column);

  GeneratedColumn<String> get inkLayerId => $composableBuilder(
    column: $table.inkLayerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sharedClubPostId => $composableBuilder(
    column: $table.sharedClubPostId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get versionHlc => $composableBuilder(
    column: $table.versionHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extras =>
      $composableBuilder(column: $table.extras, builder: (column) => column);
}

class $$AnnotationsTableTableManager
    extends
        RootTableManager<
          _$BancoSpike,
          $AnnotationsTable,
          AnotacaoLinha,
          $$AnnotationsTableFilterComposer,
          $$AnnotationsTableOrderingComposer,
          $$AnnotationsTableAnnotationComposer,
          $$AnnotationsTableCreateCompanionBuilder,
          $$AnnotationsTableUpdateCompanionBuilder,
          (
            AnotacaoLinha,
            BaseReferences<_$BancoSpike, $AnnotationsTable, AnotacaoLinha>,
          ),
          AnotacaoLinha,
          PrefetchHooks Function()
        > {
  $$AnnotationsTableTableManager(_$BancoSpike db, $AnnotationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnnotationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnnotationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnnotationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> userBookId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> anchor = const Value.absent(),
                Value<int> refPage = const Value.absent(),
                Value<int> chapterIndex = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> style = const Value.absent(),
                Value<String?> fillHeight = const Value.absent(),
                Value<String?> noteText = const Value.absent(),
                Value<String?> inkLayerId = const Value.absent(),
                Value<String?> sharedClubPostId = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> versionHlc = const Value.absent(),
                Value<String?> extras = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnnotationsCompanion(
                id: id,
                userId: userId,
                userBookId: userBookId,
                kind: kind,
                parentId: parentId,
                groupId: groupId,
                source: source,
                anchor: anchor,
                refPage: refPage,
                chapterIndex: chapterIndex,
                color: color,
                style: style,
                fillHeight: fillHeight,
                noteText: noteText,
                inkLayerId: inkLayerId,
                sharedClubPostId: sharedClubPostId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                versionHlc: versionHlc,
                extras: extras,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String userBookId,
                required String kind,
                Value<String?> parentId = const Value.absent(),
                required String groupId,
                required String source,
                required String anchor,
                required int refPage,
                required int chapterIndex,
                Value<String?> color = const Value.absent(),
                Value<String?> style = const Value.absent(),
                Value<String?> fillHeight = const Value.absent(),
                Value<String?> noteText = const Value.absent(),
                Value<String?> inkLayerId = const Value.absent(),
                Value<String?> sharedClubPostId = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String versionHlc,
                Value<String?> extras = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnnotationsCompanion.insert(
                id: id,
                userId: userId,
                userBookId: userBookId,
                kind: kind,
                parentId: parentId,
                groupId: groupId,
                source: source,
                anchor: anchor,
                refPage: refPage,
                chapterIndex: chapterIndex,
                color: color,
                style: style,
                fillHeight: fillHeight,
                noteText: noteText,
                inkLayerId: inkLayerId,
                sharedClubPostId: sharedClubPostId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                versionHlc: versionHlc,
                extras: extras,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnnotationsTable, AnotacaoLinha>(table),
                  BaseReferences<
                    _$BancoSpike,
                    $AnnotationsTable,
                    AnotacaoLinha
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnnotationsTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoSpike,
      $AnnotationsTable,
      AnotacaoLinha,
      $$AnnotationsTableFilterComposer,
      $$AnnotationsTableOrderingComposer,
      $$AnnotationsTableAnnotationComposer,
      $$AnnotationsTableCreateCompanionBuilder,
      $$AnnotationsTableUpdateCompanionBuilder,
      (
        AnotacaoLinha,
        BaseReferences<_$BancoSpike, $AnnotationsTable, AnotacaoLinha>,
      ),
      AnotacaoLinha,
      PrefetchHooks Function()
    >;

class $BancoSpikeManager {
  final _$BancoSpike _db;
  $BancoSpikeManager(this._db);
  $$UserBooksTableTableManager get userBooks =>
      $$UserBooksTableTableManager(_db, _db.userBooks);
  $$AnnotationsTableTableManager get annotations =>
      $$AnnotationsTableTableManager(_db, _db.annotations);
}
