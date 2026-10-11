// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserBooksTable extends UserBooks
    with TableInfo<$UserBooksTable, UserBookRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserBooksTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($UserBooksTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($UserBooksTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($UserBooksTable.$converterdeletedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> versionHlc =
      GeneratedColumn<String>(
        'version_hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($UserBooksTable.$converterversionHlc);
  static const VerificationMeta _extrasMeta = const VerificationMeta('extras');
  @override
  late final GeneratedColumn<String> extras = GeneratedColumn<String>(
    '_extras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  @override
  late final GeneratedColumnWithTypeConverter<BookFileFormat, String> format =
      GeneratedColumn<String>(
        'format',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<BookFileFormat>($UserBooksTable.$converterformat);
  @override
  late final GeneratedColumnWithTypeConverter<ShelfStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ShelfStatus>($UserBooksTable.$converterstatus);
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
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> addedAt =
      GeneratedColumn<String>(
        'added_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($UserBooksTable.$converteraddedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> startedAt =
      GeneratedColumn<String>(
        'started_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($UserBooksTable.$converterstartedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> finishedAt =
      GeneratedColumn<String>(
        'finished_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($UserBooksTable.$converterfinishedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> lastOpenedAt =
      GeneratedColumn<String>(
        'last_opened_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($UserBooksTable.$converterlastOpenedAtn);
  static const VerificationMeta _isbn13Meta = const VerificationMeta('isbn13');
  @override
  late final GeneratedColumn<String> isbn13 = GeneratedColumn<String>(
    'isbn13',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL CHECK (isbn13 GLOB \'97[89][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\')',
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
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
    isbn13,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserBookRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('_extras')) {
      context.handle(
        _extrasMeta,
        extras.isAcceptableOrUnknown(data['_extras']!, _extrasMeta),
      );
    }
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
    if (data.containsKey('isbn13')) {
      context.handle(
        _isbn13Meta,
        isbn13.isAcceptableOrUnknown(data['isbn13']!, _isbn13Meta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserBookRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserBookRow(
      createdAt: $UserBooksTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $UserBooksTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $UserBooksTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      versionHlc: $UserBooksTable.$converterversionHlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}version_hlc'],
        )!,
      ),
      extras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}_extras'],
      ),
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
      format: $UserBooksTable.$converterformat.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}format'],
        )!,
      ),
      status: $UserBooksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
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
      addedAt: $UserBooksTable.$converteraddedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}added_at'],
        )!,
      ),
      startedAt: $UserBooksTable.$converterstartedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}started_at'],
        ),
      ),
      finishedAt: $UserBooksTable.$converterfinishedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}finished_at'],
        ),
      ),
      lastOpenedAt: $UserBooksTable.$converterlastOpenedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}last_opened_at'],
        ),
      ),
      isbn13: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn13'],
      ),
    );
  }

  @override
  $UserBooksTable createAlias(String alias) {
    return $UserBooksTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const InstantConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<Hlc, String> $converterversionHlc = const HlcConverter();
  static TypeConverter<BookFileFormat, String> $converterformat =
      const CodeConverter(BookFileFormat.fromCode);
  static TypeConverter<ShelfStatus, String> $converterstatus =
      const CodeConverter(ShelfStatus.fromCode);
  static TypeConverter<DateTime, String> $converteraddedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterstartedAt =
      const InstantConverter();
  static TypeConverter<DateTime?, String?> $converterstartedAtn =
      NullAwareTypeConverter.wrap($converterstartedAt);
  static TypeConverter<DateTime, String> $converterfinishedAt =
      const InstantConverter();
  static TypeConverter<DateTime?, String?> $converterfinishedAtn =
      NullAwareTypeConverter.wrap($converterfinishedAt);
  static TypeConverter<DateTime, String> $converterlastOpenedAt =
      const InstantConverter();
  static TypeConverter<DateTime?, String?> $converterlastOpenedAtn =
      NullAwareTypeConverter.wrap($converterlastOpenedAt);
  @override
  bool get isStrict => true;
}

class UserBookRow extends DataClass implements Insertable<UserBookRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Hlc versionHlc;

  /// Colunas do servidor ainda desconhecidas por esta versão (parâmetro "Rest" do `put`).
  final String? extras;
  final String id;
  final String userId;
  final String? editionId;
  final String title;
  final String authorDisplay;
  final BookFileFormat format;
  final ShelfStatus status;
  final String? contentSha256;
  final int? fileBytes;
  final String? storageObjectPath;
  final int? refPagesTotal;
  final int? refPageVersion;
  final int? chaptersTotal;
  final String? coverRef;
  final int? rating;
  final DateTime addedAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime? lastOpenedAt;

  /// D-77 (esquema v2): entra no FIM da tabela, como no servidor (`alter table … add column`).
  final String? isbn13;
  const UserBookRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.versionHlc,
    this.extras,
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
    this.isbn13,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['created_at'] = Variable<String>(
        $UserBooksTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $UserBooksTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $UserBooksTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    {
      map['version_hlc'] = Variable<String>(
        $UserBooksTable.$converterversionHlc.toSql(versionHlc),
      );
    }
    if (!nullToAbsent || extras != null) {
      map['_extras'] = Variable<String>(extras);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || editionId != null) {
      map['edition_id'] = Variable<String>(editionId);
    }
    map['title'] = Variable<String>(title);
    map['author_display'] = Variable<String>(authorDisplay);
    {
      map['format'] = Variable<String>(
        $UserBooksTable.$converterformat.toSql(format),
      );
    }
    {
      map['status'] = Variable<String>(
        $UserBooksTable.$converterstatus.toSql(status),
      );
    }
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
    {
      map['added_at'] = Variable<String>(
        $UserBooksTable.$converteraddedAt.toSql(addedAt),
      );
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<String>(
        $UserBooksTable.$converterstartedAtn.toSql(startedAt),
      );
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<String>(
        $UserBooksTable.$converterfinishedAtn.toSql(finishedAt),
      );
    }
    if (!nullToAbsent || lastOpenedAt != null) {
      map['last_opened_at'] = Variable<String>(
        $UserBooksTable.$converterlastOpenedAtn.toSql(lastOpenedAt),
      );
    }
    if (!nullToAbsent || isbn13 != null) {
      map['isbn13'] = Variable<String>(isbn13);
    }
    return map;
  }

  UserBooksCompanion toCompanion(bool nullToAbsent) {
    return UserBooksCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      versionHlc: Value(versionHlc),
      extras: extras == null && nullToAbsent
          ? const Value.absent()
          : Value(extras),
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
      isbn13: isbn13 == null && nullToAbsent
          ? const Value.absent()
          : Value(isbn13),
    );
  }

  factory UserBookRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserBookRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      versionHlc: serializer.fromJson<Hlc>(json['versionHlc']),
      extras: serializer.fromJson<String?>(json['extras']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      editionId: serializer.fromJson<String?>(json['editionId']),
      title: serializer.fromJson<String>(json['title']),
      authorDisplay: serializer.fromJson<String>(json['authorDisplay']),
      format: serializer.fromJson<BookFileFormat>(json['format']),
      status: serializer.fromJson<ShelfStatus>(json['status']),
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
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      lastOpenedAt: serializer.fromJson<DateTime?>(json['lastOpenedAt']),
      isbn13: serializer.fromJson<String?>(json['isbn13']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'versionHlc': serializer.toJson<Hlc>(versionHlc),
      'extras': serializer.toJson<String?>(extras),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'editionId': serializer.toJson<String?>(editionId),
      'title': serializer.toJson<String>(title),
      'authorDisplay': serializer.toJson<String>(authorDisplay),
      'format': serializer.toJson<BookFileFormat>(format),
      'status': serializer.toJson<ShelfStatus>(status),
      'contentSha256': serializer.toJson<String?>(contentSha256),
      'fileBytes': serializer.toJson<int?>(fileBytes),
      'storageObjectPath': serializer.toJson<String?>(storageObjectPath),
      'refPagesTotal': serializer.toJson<int?>(refPagesTotal),
      'refPageVersion': serializer.toJson<int?>(refPageVersion),
      'chaptersTotal': serializer.toJson<int?>(chaptersTotal),
      'coverRef': serializer.toJson<String?>(coverRef),
      'rating': serializer.toJson<int?>(rating),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'lastOpenedAt': serializer.toJson<DateTime?>(lastOpenedAt),
      'isbn13': serializer.toJson<String?>(isbn13),
    };
  }

  UserBookRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Hlc? versionHlc,
    Value<String?> extras = const Value.absent(),
    String? id,
    String? userId,
    Value<String?> editionId = const Value.absent(),
    String? title,
    String? authorDisplay,
    BookFileFormat? format,
    ShelfStatus? status,
    Value<String?> contentSha256 = const Value.absent(),
    Value<int?> fileBytes = const Value.absent(),
    Value<String?> storageObjectPath = const Value.absent(),
    Value<int?> refPagesTotal = const Value.absent(),
    Value<int?> refPageVersion = const Value.absent(),
    Value<int?> chaptersTotal = const Value.absent(),
    Value<String?> coverRef = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    DateTime? addedAt,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> finishedAt = const Value.absent(),
    Value<DateTime?> lastOpenedAt = const Value.absent(),
    Value<String?> isbn13 = const Value.absent(),
  }) => UserBookRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    versionHlc: versionHlc ?? this.versionHlc,
    extras: extras.present ? extras.value : this.extras,
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
    isbn13: isbn13.present ? isbn13.value : this.isbn13,
  );
  UserBookRow copyWithCompanion(UserBooksCompanion data) {
    return UserBookRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      versionHlc: data.versionHlc.present
          ? data.versionHlc.value
          : this.versionHlc,
      extras: data.extras.present ? data.extras.value : this.extras,
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
      isbn13: data.isbn13.present ? data.isbn13.value : this.isbn13,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserBookRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
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
          ..write('isbn13: $isbn13')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
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
    isbn13,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserBookRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.versionHlc == this.versionHlc &&
          other.extras == this.extras &&
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
          other.isbn13 == this.isbn13);
}

class UserBooksCompanion extends UpdateCompanion<UserBookRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<Hlc> versionHlc;
  final Value<String?> extras;
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> editionId;
  final Value<String> title;
  final Value<String> authorDisplay;
  final Value<BookFileFormat> format;
  final Value<ShelfStatus> status;
  final Value<String?> contentSha256;
  final Value<int?> fileBytes;
  final Value<String?> storageObjectPath;
  final Value<int?> refPagesTotal;
  final Value<int?> refPageVersion;
  final Value<int?> chaptersTotal;
  final Value<String?> coverRef;
  final Value<int?> rating;
  final Value<DateTime> addedAt;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<DateTime?> lastOpenedAt;
  final Value<String?> isbn13;
  final Value<int> rowid;
  const UserBooksCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.versionHlc = const Value.absent(),
    this.extras = const Value.absent(),
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
    this.isbn13 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserBooksCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required Hlc versionHlc,
    this.extras = const Value.absent(),
    required String id,
    required String userId,
    this.editionId = const Value.absent(),
    required String title,
    required String authorDisplay,
    required BookFileFormat format,
    required ShelfStatus status,
    this.contentSha256 = const Value.absent(),
    this.fileBytes = const Value.absent(),
    this.storageObjectPath = const Value.absent(),
    this.refPagesTotal = const Value.absent(),
    this.refPageVersion = const Value.absent(),
    this.chaptersTotal = const Value.absent(),
    this.coverRef = const Value.absent(),
    this.rating = const Value.absent(),
    required DateTime addedAt,
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.isbn13 = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       versionHlc = Value(versionHlc),
       id = Value(id),
       userId = Value(userId),
       title = Value(title),
       authorDisplay = Value(authorDisplay),
       format = Value(format),
       status = Value(status),
       addedAt = Value(addedAt);
  static Insertable<UserBookRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? versionHlc,
    Expression<String>? extras,
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
    Expression<String>? isbn13,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (versionHlc != null) 'version_hlc': versionHlc,
      if (extras != null) '_extras': extras,
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
      if (isbn13 != null) 'isbn13': isbn13,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserBooksCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<Hlc>? versionHlc,
    Value<String?>? extras,
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? editionId,
    Value<String>? title,
    Value<String>? authorDisplay,
    Value<BookFileFormat>? format,
    Value<ShelfStatus>? status,
    Value<String?>? contentSha256,
    Value<int?>? fileBytes,
    Value<String?>? storageObjectPath,
    Value<int?>? refPagesTotal,
    Value<int?>? refPageVersion,
    Value<int?>? chaptersTotal,
    Value<String?>? coverRef,
    Value<int?>? rating,
    Value<DateTime>? addedAt,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<DateTime?>? lastOpenedAt,
    Value<String?>? isbn13,
    Value<int>? rowid,
  }) {
    return UserBooksCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      versionHlc: versionHlc ?? this.versionHlc,
      extras: extras ?? this.extras,
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
      isbn13: isbn13 ?? this.isbn13,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $UserBooksTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $UserBooksTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $UserBooksTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (versionHlc.present) {
      map['version_hlc'] = Variable<String>(
        $UserBooksTable.$converterversionHlc.toSql(versionHlc.value),
      );
    }
    if (extras.present) {
      map['_extras'] = Variable<String>(extras.value);
    }
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
      map['format'] = Variable<String>(
        $UserBooksTable.$converterformat.toSql(format.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $UserBooksTable.$converterstatus.toSql(status.value),
      );
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
      map['added_at'] = Variable<String>(
        $UserBooksTable.$converteraddedAt.toSql(addedAt.value),
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<String>(
        $UserBooksTable.$converterstartedAtn.toSql(startedAt.value),
      );
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<String>(
        $UserBooksTable.$converterfinishedAtn.toSql(finishedAt.value),
      );
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<String>(
        $UserBooksTable.$converterlastOpenedAtn.toSql(lastOpenedAt.value),
      );
    }
    if (isbn13.present) {
      map['isbn13'] = Variable<String>(isbn13.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserBooksCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
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
          ..write('isbn13: $isbn13, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingPositionsTable extends ReadingPositions
    with TableInfo<$ReadingPositionsTable, ReadingPositionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingPositionsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReadingPositionsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReadingPositionsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ReadingPositionsTable.$converterdeletedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> versionHlc =
      GeneratedColumn<String>(
        'version_hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($ReadingPositionsTable.$converterversionHlc);
  static const VerificationMeta _extrasMeta = const VerificationMeta('extras');
  @override
  late final GeneratedColumn<String> extras = GeneratedColumn<String>(
    '_extras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  @override
  late final GeneratedColumnWithTypeConverter<Locator, String> locator =
      GeneratedColumn<String>(
        'locator',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Locator>($ReadingPositionsTable.$converterlocator);
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
  @override
  late final GeneratedColumnWithTypeConverter<double, String> progression =
      GeneratedColumn<String>(
        'progression',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<double>($ReadingPositionsTable.$converterprogression);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    locator,
    refPage,
    chapterIndex,
    progression,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_positions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingPositionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('_extras')) {
      context.handle(
        _extrasMeta,
        extras.isAcceptableOrUnknown(data['_extras']!, _extrasMeta),
      );
    }
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
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingPositionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingPositionRow(
      createdAt: $ReadingPositionsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $ReadingPositionsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $ReadingPositionsTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      versionHlc: $ReadingPositionsTable.$converterversionHlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}version_hlc'],
        )!,
      ),
      extras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}_extras'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      locator: $ReadingPositionsTable.$converterlocator.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}locator'],
        )!,
      ),
      refPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ref_page'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      progression: $ReadingPositionsTable.$converterprogression.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}progression'],
        )!,
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $ReadingPositionsTable createAlias(String alias) {
    return $ReadingPositionsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const InstantConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<Hlc, String> $converterversionHlc = const HlcConverter();
  static TypeConverter<Locator, String> $converterlocator =
      const LocatorConverter();
  static TypeConverter<double, String> $converterprogression =
      const DecimalTextConverter(5);
  @override
  bool get isStrict => true;
}

class ReadingPositionRow extends DataClass
    implements Insertable<ReadingPositionRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Hlc versionHlc;

  /// Colunas do servidor ainda desconhecidas por esta versão (parâmetro "Rest" do `put`).
  final String? extras;
  final String id;
  final String userId;
  final Locator locator;
  final int refPage;
  final int chapterIndex;
  final double progression;
  final String? deviceId;
  const ReadingPositionRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.versionHlc,
    this.extras,
    required this.id,
    required this.userId,
    required this.locator,
    required this.refPage,
    required this.chapterIndex,
    required this.progression,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['created_at'] = Variable<String>(
        $ReadingPositionsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $ReadingPositionsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $ReadingPositionsTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    {
      map['version_hlc'] = Variable<String>(
        $ReadingPositionsTable.$converterversionHlc.toSql(versionHlc),
      );
    }
    if (!nullToAbsent || extras != null) {
      map['_extras'] = Variable<String>(extras);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    {
      map['locator'] = Variable<String>(
        $ReadingPositionsTable.$converterlocator.toSql(locator),
      );
    }
    map['ref_page'] = Variable<int>(refPage);
    map['chapter_index'] = Variable<int>(chapterIndex);
    {
      map['progression'] = Variable<String>(
        $ReadingPositionsTable.$converterprogression.toSql(progression),
      );
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  ReadingPositionsCompanion toCompanion(bool nullToAbsent) {
    return ReadingPositionsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      versionHlc: Value(versionHlc),
      extras: extras == null && nullToAbsent
          ? const Value.absent()
          : Value(extras),
      id: Value(id),
      userId: Value(userId),
      locator: Value(locator),
      refPage: Value(refPage),
      chapterIndex: Value(chapterIndex),
      progression: Value(progression),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory ReadingPositionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingPositionRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      versionHlc: serializer.fromJson<Hlc>(json['versionHlc']),
      extras: serializer.fromJson<String?>(json['extras']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      locator: serializer.fromJson<Locator>(json['locator']),
      refPage: serializer.fromJson<int>(json['refPage']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      progression: serializer.fromJson<double>(json['progression']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'versionHlc': serializer.toJson<Hlc>(versionHlc),
      'extras': serializer.toJson<String?>(extras),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'locator': serializer.toJson<Locator>(locator),
      'refPage': serializer.toJson<int>(refPage),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'progression': serializer.toJson<double>(progression),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  ReadingPositionRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Hlc? versionHlc,
    Value<String?> extras = const Value.absent(),
    String? id,
    String? userId,
    Locator? locator,
    int? refPage,
    int? chapterIndex,
    double? progression,
    Value<String?> deviceId = const Value.absent(),
  }) => ReadingPositionRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    versionHlc: versionHlc ?? this.versionHlc,
    extras: extras.present ? extras.value : this.extras,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    locator: locator ?? this.locator,
    refPage: refPage ?? this.refPage,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    progression: progression ?? this.progression,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  ReadingPositionRow copyWithCompanion(ReadingPositionsCompanion data) {
    return ReadingPositionRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      versionHlc: data.versionHlc.present
          ? data.versionHlc.value
          : this.versionHlc,
      extras: data.extras.present ? data.extras.value : this.extras,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      locator: data.locator.present ? data.locator.value : this.locator,
      refPage: data.refPage.present ? data.refPage.value : this.refPage,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      progression: data.progression.present
          ? data.progression.value
          : this.progression,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingPositionRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('locator: $locator, ')
          ..write('refPage: $refPage, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('progression: $progression, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    locator,
    refPage,
    chapterIndex,
    progression,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingPositionRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.versionHlc == this.versionHlc &&
          other.extras == this.extras &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.locator == this.locator &&
          other.refPage == this.refPage &&
          other.chapterIndex == this.chapterIndex &&
          other.progression == this.progression &&
          other.deviceId == this.deviceId);
}

class ReadingPositionsCompanion extends UpdateCompanion<ReadingPositionRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<Hlc> versionHlc;
  final Value<String?> extras;
  final Value<String> id;
  final Value<String> userId;
  final Value<Locator> locator;
  final Value<int> refPage;
  final Value<int> chapterIndex;
  final Value<double> progression;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const ReadingPositionsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.versionHlc = const Value.absent(),
    this.extras = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.locator = const Value.absent(),
    this.refPage = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.progression = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingPositionsCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required Hlc versionHlc,
    this.extras = const Value.absent(),
    required String id,
    required String userId,
    required Locator locator,
    required int refPage,
    required int chapterIndex,
    required double progression,
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       versionHlc = Value(versionHlc),
       id = Value(id),
       userId = Value(userId),
       locator = Value(locator),
       refPage = Value(refPage),
       chapterIndex = Value(chapterIndex),
       progression = Value(progression);
  static Insertable<ReadingPositionRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? versionHlc,
    Expression<String>? extras,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? locator,
    Expression<int>? refPage,
    Expression<int>? chapterIndex,
    Expression<String>? progression,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (versionHlc != null) 'version_hlc': versionHlc,
      if (extras != null) '_extras': extras,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (locator != null) 'locator': locator,
      if (refPage != null) 'ref_page': refPage,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (progression != null) 'progression': progression,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingPositionsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<Hlc>? versionHlc,
    Value<String?>? extras,
    Value<String>? id,
    Value<String>? userId,
    Value<Locator>? locator,
    Value<int>? refPage,
    Value<int>? chapterIndex,
    Value<double>? progression,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return ReadingPositionsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      versionHlc: versionHlc ?? this.versionHlc,
      extras: extras ?? this.extras,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      locator: locator ?? this.locator,
      refPage: refPage ?? this.refPage,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      progression: progression ?? this.progression,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $ReadingPositionsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $ReadingPositionsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $ReadingPositionsTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (versionHlc.present) {
      map['version_hlc'] = Variable<String>(
        $ReadingPositionsTable.$converterversionHlc.toSql(versionHlc.value),
      );
    }
    if (extras.present) {
      map['_extras'] = Variable<String>(extras.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (locator.present) {
      map['locator'] = Variable<String>(
        $ReadingPositionsTable.$converterlocator.toSql(locator.value),
      );
    }
    if (refPage.present) {
      map['ref_page'] = Variable<int>(refPage.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (progression.present) {
      map['progression'] = Variable<String>(
        $ReadingPositionsTable.$converterprogression.toSql(progression.value),
      );
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingPositionsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('locator: $locator, ')
          ..write('refPage: $refPage, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('progression: $progression, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingSessionsTable extends ReadingSessions
    with TableInfo<$ReadingSessionsTable, ReadingSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingSessionsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReadingSessionsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReadingSessionsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ReadingSessionsTable.$converterdeletedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> versionHlc =
      GeneratedColumn<String>(
        'version_hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($ReadingSessionsTable.$converterversionHlc);
  static const VerificationMeta _extrasMeta = const VerificationMeta('extras');
  @override
  late final GeneratedColumn<String> extras = GeneratedColumn<String>(
    '_extras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> startedAt =
      GeneratedColumn<String>(
        'started_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReadingSessionsTable.$converterstartedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> endedAt =
      GeneratedColumn<String>(
        'ended_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReadingSessionsTable.$converterendedAt);
  static const VerificationMeta _activeSecondsMeta = const VerificationMeta(
    'activeSeconds',
  );
  @override
  late final GeneratedColumn<int> activeSeconds = GeneratedColumn<int>(
    'active_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refPageFromMeta = const VerificationMeta(
    'refPageFrom',
  );
  @override
  late final GeneratedColumn<int> refPageFrom = GeneratedColumn<int>(
    'ref_page_from',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refPageToMeta = const VerificationMeta(
    'refPageTo',
  );
  @override
  late final GeneratedColumn<int> refPageTo = GeneratedColumn<int>(
    'ref_page_to',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pagesViewedMeta = const VerificationMeta(
    'pagesViewed',
  );
  @override
  late final GeneratedColumn<int> pagesViewed = GeneratedColumn<int>(
    'pages_viewed',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionSource>($ReadingSessionsTable.$convertersource);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    userBookId,
    startedAt,
    endedAt,
    activeSeconds,
    refPageFrom,
    refPageTo,
    pagesViewed,
    source,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('_extras')) {
      context.handle(
        _extrasMeta,
        extras.isAcceptableOrUnknown(data['_extras']!, _extrasMeta),
      );
    }
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
    if (data.containsKey('active_seconds')) {
      context.handle(
        _activeSecondsMeta,
        activeSeconds.isAcceptableOrUnknown(
          data['active_seconds']!,
          _activeSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeSecondsMeta);
    }
    if (data.containsKey('ref_page_from')) {
      context.handle(
        _refPageFromMeta,
        refPageFrom.isAcceptableOrUnknown(
          data['ref_page_from']!,
          _refPageFromMeta,
        ),
      );
    }
    if (data.containsKey('ref_page_to')) {
      context.handle(
        _refPageToMeta,
        refPageTo.isAcceptableOrUnknown(data['ref_page_to']!, _refPageToMeta),
      );
    }
    if (data.containsKey('pages_viewed')) {
      context.handle(
        _pagesViewedMeta,
        pagesViewed.isAcceptableOrUnknown(
          data['pages_viewed']!,
          _pagesViewedMeta,
        ),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingSessionRow(
      createdAt: $ReadingSessionsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $ReadingSessionsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $ReadingSessionsTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      versionHlc: $ReadingSessionsTable.$converterversionHlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}version_hlc'],
        )!,
      ),
      extras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}_extras'],
      ),
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
      startedAt: $ReadingSessionsTable.$converterstartedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}started_at'],
        )!,
      ),
      endedAt: $ReadingSessionsTable.$converterendedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}ended_at'],
        )!,
      ),
      activeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_seconds'],
      )!,
      refPageFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ref_page_from'],
      ),
      refPageTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ref_page_to'],
      ),
      pagesViewed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages_viewed'],
      ),
      source: $ReadingSessionsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $ReadingSessionsTable createAlias(String alias) {
    return $ReadingSessionsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const InstantConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<Hlc, String> $converterversionHlc = const HlcConverter();
  static TypeConverter<DateTime, String> $converterstartedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterendedAt =
      const InstantConverter();
  static TypeConverter<SessionSource, String> $convertersource =
      const CodeConverter(SessionSource.fromCode);
  @override
  bool get isStrict => true;
}

class ReadingSessionRow extends DataClass
    implements Insertable<ReadingSessionRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Hlc versionHlc;

  /// Colunas do servidor ainda desconhecidas por esta versão (parâmetro "Rest" do `put`).
  final String? extras;
  final String id;
  final String userId;
  final String userBookId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int activeSeconds;
  final int? refPageFrom;
  final int? refPageTo;
  final int? pagesViewed;
  final SessionSource source;
  final String? deviceId;
  const ReadingSessionRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.versionHlc,
    this.extras,
    required this.id,
    required this.userId,
    required this.userBookId,
    required this.startedAt,
    required this.endedAt,
    required this.activeSeconds,
    this.refPageFrom,
    this.refPageTo,
    this.pagesViewed,
    required this.source,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['created_at'] = Variable<String>(
        $ReadingSessionsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $ReadingSessionsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $ReadingSessionsTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    {
      map['version_hlc'] = Variable<String>(
        $ReadingSessionsTable.$converterversionHlc.toSql(versionHlc),
      );
    }
    if (!nullToAbsent || extras != null) {
      map['_extras'] = Variable<String>(extras);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['user_book_id'] = Variable<String>(userBookId);
    {
      map['started_at'] = Variable<String>(
        $ReadingSessionsTable.$converterstartedAt.toSql(startedAt),
      );
    }
    {
      map['ended_at'] = Variable<String>(
        $ReadingSessionsTable.$converterendedAt.toSql(endedAt),
      );
    }
    map['active_seconds'] = Variable<int>(activeSeconds);
    if (!nullToAbsent || refPageFrom != null) {
      map['ref_page_from'] = Variable<int>(refPageFrom);
    }
    if (!nullToAbsent || refPageTo != null) {
      map['ref_page_to'] = Variable<int>(refPageTo);
    }
    if (!nullToAbsent || pagesViewed != null) {
      map['pages_viewed'] = Variable<int>(pagesViewed);
    }
    {
      map['source'] = Variable<String>(
        $ReadingSessionsTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  ReadingSessionsCompanion toCompanion(bool nullToAbsent) {
    return ReadingSessionsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      versionHlc: Value(versionHlc),
      extras: extras == null && nullToAbsent
          ? const Value.absent()
          : Value(extras),
      id: Value(id),
      userId: Value(userId),
      userBookId: Value(userBookId),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      activeSeconds: Value(activeSeconds),
      refPageFrom: refPageFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(refPageFrom),
      refPageTo: refPageTo == null && nullToAbsent
          ? const Value.absent()
          : Value(refPageTo),
      pagesViewed: pagesViewed == null && nullToAbsent
          ? const Value.absent()
          : Value(pagesViewed),
      source: Value(source),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory ReadingSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingSessionRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      versionHlc: serializer.fromJson<Hlc>(json['versionHlc']),
      extras: serializer.fromJson<String?>(json['extras']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      userBookId: serializer.fromJson<String>(json['userBookId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      activeSeconds: serializer.fromJson<int>(json['activeSeconds']),
      refPageFrom: serializer.fromJson<int?>(json['refPageFrom']),
      refPageTo: serializer.fromJson<int?>(json['refPageTo']),
      pagesViewed: serializer.fromJson<int?>(json['pagesViewed']),
      source: serializer.fromJson<SessionSource>(json['source']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'versionHlc': serializer.toJson<Hlc>(versionHlc),
      'extras': serializer.toJson<String?>(extras),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'userBookId': serializer.toJson<String>(userBookId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'activeSeconds': serializer.toJson<int>(activeSeconds),
      'refPageFrom': serializer.toJson<int?>(refPageFrom),
      'refPageTo': serializer.toJson<int?>(refPageTo),
      'pagesViewed': serializer.toJson<int?>(pagesViewed),
      'source': serializer.toJson<SessionSource>(source),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  ReadingSessionRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Hlc? versionHlc,
    Value<String?> extras = const Value.absent(),
    String? id,
    String? userId,
    String? userBookId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? activeSeconds,
    Value<int?> refPageFrom = const Value.absent(),
    Value<int?> refPageTo = const Value.absent(),
    Value<int?> pagesViewed = const Value.absent(),
    SessionSource? source,
    Value<String?> deviceId = const Value.absent(),
  }) => ReadingSessionRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    versionHlc: versionHlc ?? this.versionHlc,
    extras: extras.present ? extras.value : this.extras,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    userBookId: userBookId ?? this.userBookId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    activeSeconds: activeSeconds ?? this.activeSeconds,
    refPageFrom: refPageFrom.present ? refPageFrom.value : this.refPageFrom,
    refPageTo: refPageTo.present ? refPageTo.value : this.refPageTo,
    pagesViewed: pagesViewed.present ? pagesViewed.value : this.pagesViewed,
    source: source ?? this.source,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  ReadingSessionRow copyWithCompanion(ReadingSessionsCompanion data) {
    return ReadingSessionRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      versionHlc: data.versionHlc.present
          ? data.versionHlc.value
          : this.versionHlc,
      extras: data.extras.present ? data.extras.value : this.extras,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      userBookId: data.userBookId.present
          ? data.userBookId.value
          : this.userBookId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      activeSeconds: data.activeSeconds.present
          ? data.activeSeconds.value
          : this.activeSeconds,
      refPageFrom: data.refPageFrom.present
          ? data.refPageFrom.value
          : this.refPageFrom,
      refPageTo: data.refPageTo.present ? data.refPageTo.value : this.refPageTo,
      pagesViewed: data.pagesViewed.present
          ? data.pagesViewed.value
          : this.pagesViewed,
      source: data.source.present ? data.source.value : this.source,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userBookId: $userBookId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('activeSeconds: $activeSeconds, ')
          ..write('refPageFrom: $refPageFrom, ')
          ..write('refPageTo: $refPageTo, ')
          ..write('pagesViewed: $pagesViewed, ')
          ..write('source: $source, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    userBookId,
    startedAt,
    endedAt,
    activeSeconds,
    refPageFrom,
    refPageTo,
    pagesViewed,
    source,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingSessionRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.versionHlc == this.versionHlc &&
          other.extras == this.extras &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.userBookId == this.userBookId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.activeSeconds == this.activeSeconds &&
          other.refPageFrom == this.refPageFrom &&
          other.refPageTo == this.refPageTo &&
          other.pagesViewed == this.pagesViewed &&
          other.source == this.source &&
          other.deviceId == this.deviceId);
}

class ReadingSessionsCompanion extends UpdateCompanion<ReadingSessionRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<Hlc> versionHlc;
  final Value<String?> extras;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> userBookId;
  final Value<DateTime> startedAt;
  final Value<DateTime> endedAt;
  final Value<int> activeSeconds;
  final Value<int?> refPageFrom;
  final Value<int?> refPageTo;
  final Value<int?> pagesViewed;
  final Value<SessionSource> source;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const ReadingSessionsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.versionHlc = const Value.absent(),
    this.extras = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.userBookId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.activeSeconds = const Value.absent(),
    this.refPageFrom = const Value.absent(),
    this.refPageTo = const Value.absent(),
    this.pagesViewed = const Value.absent(),
    this.source = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingSessionsCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required Hlc versionHlc,
    this.extras = const Value.absent(),
    required String id,
    required String userId,
    required String userBookId,
    required DateTime startedAt,
    required DateTime endedAt,
    required int activeSeconds,
    this.refPageFrom = const Value.absent(),
    this.refPageTo = const Value.absent(),
    this.pagesViewed = const Value.absent(),
    required SessionSource source,
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       versionHlc = Value(versionHlc),
       id = Value(id),
       userId = Value(userId),
       userBookId = Value(userBookId),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       activeSeconds = Value(activeSeconds),
       source = Value(source);
  static Insertable<ReadingSessionRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? versionHlc,
    Expression<String>? extras,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? userBookId,
    Expression<String>? startedAt,
    Expression<String>? endedAt,
    Expression<int>? activeSeconds,
    Expression<int>? refPageFrom,
    Expression<int>? refPageTo,
    Expression<int>? pagesViewed,
    Expression<String>? source,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (versionHlc != null) 'version_hlc': versionHlc,
      if (extras != null) '_extras': extras,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (userBookId != null) 'user_book_id': userBookId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (activeSeconds != null) 'active_seconds': activeSeconds,
      if (refPageFrom != null) 'ref_page_from': refPageFrom,
      if (refPageTo != null) 'ref_page_to': refPageTo,
      if (pagesViewed != null) 'pages_viewed': pagesViewed,
      if (source != null) 'source': source,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingSessionsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<Hlc>? versionHlc,
    Value<String?>? extras,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? userBookId,
    Value<DateTime>? startedAt,
    Value<DateTime>? endedAt,
    Value<int>? activeSeconds,
    Value<int?>? refPageFrom,
    Value<int?>? refPageTo,
    Value<int?>? pagesViewed,
    Value<SessionSource>? source,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return ReadingSessionsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      versionHlc: versionHlc ?? this.versionHlc,
      extras: extras ?? this.extras,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userBookId: userBookId ?? this.userBookId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      activeSeconds: activeSeconds ?? this.activeSeconds,
      refPageFrom: refPageFrom ?? this.refPageFrom,
      refPageTo: refPageTo ?? this.refPageTo,
      pagesViewed: pagesViewed ?? this.pagesViewed,
      source: source ?? this.source,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $ReadingSessionsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $ReadingSessionsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $ReadingSessionsTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (versionHlc.present) {
      map['version_hlc'] = Variable<String>(
        $ReadingSessionsTable.$converterversionHlc.toSql(versionHlc.value),
      );
    }
    if (extras.present) {
      map['_extras'] = Variable<String>(extras.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (userBookId.present) {
      map['user_book_id'] = Variable<String>(userBookId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<String>(
        $ReadingSessionsTable.$converterstartedAt.toSql(startedAt.value),
      );
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<String>(
        $ReadingSessionsTable.$converterendedAt.toSql(endedAt.value),
      );
    }
    if (activeSeconds.present) {
      map['active_seconds'] = Variable<int>(activeSeconds.value);
    }
    if (refPageFrom.present) {
      map['ref_page_from'] = Variable<int>(refPageFrom.value);
    }
    if (refPageTo.present) {
      map['ref_page_to'] = Variable<int>(refPageTo.value);
    }
    if (pagesViewed.present) {
      map['pages_viewed'] = Variable<int>(pagesViewed.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $ReadingSessionsTable.$convertersource.toSql(source.value),
      );
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userBookId: $userBookId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('activeSeconds: $activeSeconds, ')
          ..write('refPageFrom: $refPageFrom, ')
          ..write('refPageTo: $refPageTo, ')
          ..write('pagesViewed: $pagesViewed, ')
          ..write('source: $source, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, BookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($BookmarksTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($BookmarksTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($BookmarksTable.$converterdeletedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> versionHlc =
      GeneratedColumn<String>(
        'version_hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($BookmarksTable.$converterversionHlc);
  static const VerificationMeta _extrasMeta = const VerificationMeta('extras');
  @override
  late final GeneratedColumn<String> extras = GeneratedColumn<String>(
    '_extras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  @override
  late final GeneratedColumnWithTypeConverter<Locator, String> locator =
      GeneratedColumn<String>(
        'locator',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Locator>($BookmarksTable.$converterlocator);
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
  static const VerificationMeta _excerptMeta = const VerificationMeta(
    'excerpt',
  );
  @override
  late final GeneratedColumn<String> excerpt = GeneratedColumn<String>(
    'excerpt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    userBookId,
    locator,
    refPage,
    chapterIndex,
    excerpt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('_extras')) {
      context.handle(
        _extrasMeta,
        extras.isAcceptableOrUnknown(data['_extras']!, _extrasMeta),
      );
    }
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
    if (data.containsKey('excerpt')) {
      context.handle(
        _excerptMeta,
        excerpt.isAcceptableOrUnknown(data['excerpt']!, _excerptMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkRow(
      createdAt: $BookmarksTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $BookmarksTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $BookmarksTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      versionHlc: $BookmarksTable.$converterversionHlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}version_hlc'],
        )!,
      ),
      extras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}_extras'],
      ),
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
      locator: $BookmarksTable.$converterlocator.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}locator'],
        )!,
      ),
      refPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ref_page'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      excerpt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}excerpt'],
      ),
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const InstantConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<Hlc, String> $converterversionHlc = const HlcConverter();
  static TypeConverter<Locator, String> $converterlocator =
      const LocatorConverter();
  @override
  bool get isStrict => true;
}

class BookmarkRow extends DataClass implements Insertable<BookmarkRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Hlc versionHlc;

  /// Colunas do servidor ainda desconhecidas por esta versão (parâmetro "Rest" do `put`).
  final String? extras;
  final String id;
  final String userId;
  final String userBookId;
  final Locator locator;
  final int refPage;
  final int chapterIndex;
  final String? excerpt;
  const BookmarkRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.versionHlc,
    this.extras,
    required this.id,
    required this.userId,
    required this.userBookId,
    required this.locator,
    required this.refPage,
    required this.chapterIndex,
    this.excerpt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['created_at'] = Variable<String>(
        $BookmarksTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $BookmarksTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $BookmarksTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    {
      map['version_hlc'] = Variable<String>(
        $BookmarksTable.$converterversionHlc.toSql(versionHlc),
      );
    }
    if (!nullToAbsent || extras != null) {
      map['_extras'] = Variable<String>(extras);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['user_book_id'] = Variable<String>(userBookId);
    {
      map['locator'] = Variable<String>(
        $BookmarksTable.$converterlocator.toSql(locator),
      );
    }
    map['ref_page'] = Variable<int>(refPage);
    map['chapter_index'] = Variable<int>(chapterIndex);
    if (!nullToAbsent || excerpt != null) {
      map['excerpt'] = Variable<String>(excerpt);
    }
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      versionHlc: Value(versionHlc),
      extras: extras == null && nullToAbsent
          ? const Value.absent()
          : Value(extras),
      id: Value(id),
      userId: Value(userId),
      userBookId: Value(userBookId),
      locator: Value(locator),
      refPage: Value(refPage),
      chapterIndex: Value(chapterIndex),
      excerpt: excerpt == null && nullToAbsent
          ? const Value.absent()
          : Value(excerpt),
    );
  }

  factory BookmarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      versionHlc: serializer.fromJson<Hlc>(json['versionHlc']),
      extras: serializer.fromJson<String?>(json['extras']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      userBookId: serializer.fromJson<String>(json['userBookId']),
      locator: serializer.fromJson<Locator>(json['locator']),
      refPage: serializer.fromJson<int>(json['refPage']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      excerpt: serializer.fromJson<String?>(json['excerpt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'versionHlc': serializer.toJson<Hlc>(versionHlc),
      'extras': serializer.toJson<String?>(extras),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'userBookId': serializer.toJson<String>(userBookId),
      'locator': serializer.toJson<Locator>(locator),
      'refPage': serializer.toJson<int>(refPage),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'excerpt': serializer.toJson<String?>(excerpt),
    };
  }

  BookmarkRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Hlc? versionHlc,
    Value<String?> extras = const Value.absent(),
    String? id,
    String? userId,
    String? userBookId,
    Locator? locator,
    int? refPage,
    int? chapterIndex,
    Value<String?> excerpt = const Value.absent(),
  }) => BookmarkRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    versionHlc: versionHlc ?? this.versionHlc,
    extras: extras.present ? extras.value : this.extras,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    userBookId: userBookId ?? this.userBookId,
    locator: locator ?? this.locator,
    refPage: refPage ?? this.refPage,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    excerpt: excerpt.present ? excerpt.value : this.excerpt,
  );
  BookmarkRow copyWithCompanion(BookmarksCompanion data) {
    return BookmarkRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      versionHlc: data.versionHlc.present
          ? data.versionHlc.value
          : this.versionHlc,
      extras: data.extras.present ? data.extras.value : this.extras,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      userBookId: data.userBookId.present
          ? data.userBookId.value
          : this.userBookId,
      locator: data.locator.present ? data.locator.value : this.locator,
      refPage: data.refPage.present ? data.refPage.value : this.refPage,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      excerpt: data.excerpt.present ? data.excerpt.value : this.excerpt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userBookId: $userBookId, ')
          ..write('locator: $locator, ')
          ..write('refPage: $refPage, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('excerpt: $excerpt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    userBookId,
    locator,
    refPage,
    chapterIndex,
    excerpt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.versionHlc == this.versionHlc &&
          other.extras == this.extras &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.userBookId == this.userBookId &&
          other.locator == this.locator &&
          other.refPage == this.refPage &&
          other.chapterIndex == this.chapterIndex &&
          other.excerpt == this.excerpt);
}

class BookmarksCompanion extends UpdateCompanion<BookmarkRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<Hlc> versionHlc;
  final Value<String?> extras;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> userBookId;
  final Value<Locator> locator;
  final Value<int> refPage;
  final Value<int> chapterIndex;
  final Value<String?> excerpt;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.versionHlc = const Value.absent(),
    this.extras = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.userBookId = const Value.absent(),
    this.locator = const Value.absent(),
    this.refPage = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.excerpt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required Hlc versionHlc,
    this.extras = const Value.absent(),
    required String id,
    required String userId,
    required String userBookId,
    required Locator locator,
    required int refPage,
    required int chapterIndex,
    this.excerpt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       versionHlc = Value(versionHlc),
       id = Value(id),
       userId = Value(userId),
       userBookId = Value(userBookId),
       locator = Value(locator),
       refPage = Value(refPage),
       chapterIndex = Value(chapterIndex);
  static Insertable<BookmarkRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? versionHlc,
    Expression<String>? extras,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? userBookId,
    Expression<String>? locator,
    Expression<int>? refPage,
    Expression<int>? chapterIndex,
    Expression<String>? excerpt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (versionHlc != null) 'version_hlc': versionHlc,
      if (extras != null) '_extras': extras,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (userBookId != null) 'user_book_id': userBookId,
      if (locator != null) 'locator': locator,
      if (refPage != null) 'ref_page': refPage,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (excerpt != null) 'excerpt': excerpt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<Hlc>? versionHlc,
    Value<String?>? extras,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? userBookId,
    Value<Locator>? locator,
    Value<int>? refPage,
    Value<int>? chapterIndex,
    Value<String?>? excerpt,
    Value<int>? rowid,
  }) {
    return BookmarksCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      versionHlc: versionHlc ?? this.versionHlc,
      extras: extras ?? this.extras,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userBookId: userBookId ?? this.userBookId,
      locator: locator ?? this.locator,
      refPage: refPage ?? this.refPage,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      excerpt: excerpt ?? this.excerpt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $BookmarksTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $BookmarksTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $BookmarksTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (versionHlc.present) {
      map['version_hlc'] = Variable<String>(
        $BookmarksTable.$converterversionHlc.toSql(versionHlc.value),
      );
    }
    if (extras.present) {
      map['_extras'] = Variable<String>(extras.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (userBookId.present) {
      map['user_book_id'] = Variable<String>(userBookId.value);
    }
    if (locator.present) {
      map['locator'] = Variable<String>(
        $BookmarksTable.$converterlocator.toSql(locator.value),
      );
    }
    if (refPage.present) {
      map['ref_page'] = Variable<int>(refPage.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (excerpt.present) {
      map['excerpt'] = Variable<String>(excerpt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userBookId: $userBookId, ')
          ..write('locator: $locator, ')
          ..write('refPage: $refPage, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('excerpt: $excerpt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InkLayersTable extends InkLayers
    with TableInfo<$InkLayersTable, InkLayerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InkLayersTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($InkLayersTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($InkLayersTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($InkLayersTable.$converterdeletedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> versionHlc =
      GeneratedColumn<String>(
        'version_hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($InkLayersTable.$converterversionHlc);
  static const VerificationMeta _extrasMeta = const VerificationMeta('extras');
  @override
  late final GeneratedColumn<String> extras = GeneratedColumn<String>(
    '_extras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  @override
  late final GeneratedColumnWithTypeConverter<InkLayerKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<InkLayerKind>($InkLayersTable.$converterkind);
  @override
  late final GeneratedColumnWithTypeConverter<TextAnchor, String> anchor =
      GeneratedColumn<String>(
        'anchor',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TextAnchor>($InkLayersTable.$converteranchor);
  static const VerificationMeta _spaceLinesMeta = const VerificationMeta(
    'spaceLines',
  );
  @override
  late final GeneratedColumn<int> spaceLines = GeneratedColumn<int>(
    'space_lines',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collapsedMeta = const VerificationMeta(
    'collapsed',
  );
  @override
  late final GeneratedColumn<bool> collapsed = GeneratedColumn<bool>(
    'collapsed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("collapsed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _strokesB64Meta = const VerificationMeta(
    'strokesB64',
  );
  @override
  late final GeneratedColumn<String> strokesB64 = GeneratedColumn<String>(
    'strokes_b64',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strokeCountMeta = const VerificationMeta(
    'strokeCount',
  );
  @override
  late final GeneratedColumn<int> strokeCount = GeneratedColumn<int>(
    'stroke_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codecVersionMeta = const VerificationMeta(
    'codecVersion',
  );
  @override
  late final GeneratedColumn<int> codecVersion = GeneratedColumn<int>(
    'codec_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    userBookId,
    kind,
    anchor,
    spaceLines,
    collapsed,
    strokesB64,
    strokeCount,
    codecVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ink_layers';
  @override
  VerificationContext validateIntegrity(
    Insertable<InkLayerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('_extras')) {
      context.handle(
        _extrasMeta,
        extras.isAcceptableOrUnknown(data['_extras']!, _extrasMeta),
      );
    }
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
    if (data.containsKey('space_lines')) {
      context.handle(
        _spaceLinesMeta,
        spaceLines.isAcceptableOrUnknown(data['space_lines']!, _spaceLinesMeta),
      );
    }
    if (data.containsKey('collapsed')) {
      context.handle(
        _collapsedMeta,
        collapsed.isAcceptableOrUnknown(data['collapsed']!, _collapsedMeta),
      );
    }
    if (data.containsKey('strokes_b64')) {
      context.handle(
        _strokesB64Meta,
        strokesB64.isAcceptableOrUnknown(data['strokes_b64']!, _strokesB64Meta),
      );
    } else if (isInserting) {
      context.missing(_strokesB64Meta);
    }
    if (data.containsKey('stroke_count')) {
      context.handle(
        _strokeCountMeta,
        strokeCount.isAcceptableOrUnknown(
          data['stroke_count']!,
          _strokeCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strokeCountMeta);
    }
    if (data.containsKey('codec_version')) {
      context.handle(
        _codecVersionMeta,
        codecVersion.isAcceptableOrUnknown(
          data['codec_version']!,
          _codecVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InkLayerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InkLayerRow(
      createdAt: $InkLayersTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $InkLayersTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $InkLayersTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      versionHlc: $InkLayersTable.$converterversionHlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}version_hlc'],
        )!,
      ),
      extras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}_extras'],
      ),
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
      kind: $InkLayersTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      anchor: $InkLayersTable.$converteranchor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}anchor'],
        )!,
      ),
      spaceLines: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}space_lines'],
      ),
      collapsed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}collapsed'],
      )!,
      strokesB64: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strokes_b64'],
      )!,
      strokeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stroke_count'],
      )!,
      codecVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}codec_version'],
      )!,
    );
  }

  @override
  $InkLayersTable createAlias(String alias) {
    return $InkLayersTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const InstantConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<Hlc, String> $converterversionHlc = const HlcConverter();
  static TypeConverter<InkLayerKind, String> $converterkind =
      const CodeConverter(InkLayerKind.fromCode);
  static TypeConverter<TextAnchor, String> $converteranchor =
      const AnchorConverter();
  @override
  bool get isStrict => true;
}

class InkLayerRow extends DataClass implements Insertable<InkLayerRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Hlc versionHlc;

  /// Colunas do servidor ainda desconhecidas por esta versão (parâmetro "Rest" do `put`).
  final String? extras;
  final String id;
  final String userId;
  final String userBookId;
  final InkLayerKind kind;
  final TextAnchor anchor;
  final int? spaceLines;
  final bool collapsed;
  final String strokesB64;
  final int strokeCount;
  final int codecVersion;
  const InkLayerRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.versionHlc,
    this.extras,
    required this.id,
    required this.userId,
    required this.userBookId,
    required this.kind,
    required this.anchor,
    this.spaceLines,
    required this.collapsed,
    required this.strokesB64,
    required this.strokeCount,
    required this.codecVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['created_at'] = Variable<String>(
        $InkLayersTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $InkLayersTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $InkLayersTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    {
      map['version_hlc'] = Variable<String>(
        $InkLayersTable.$converterversionHlc.toSql(versionHlc),
      );
    }
    if (!nullToAbsent || extras != null) {
      map['_extras'] = Variable<String>(extras);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['user_book_id'] = Variable<String>(userBookId);
    {
      map['kind'] = Variable<String>(
        $InkLayersTable.$converterkind.toSql(kind),
      );
    }
    {
      map['anchor'] = Variable<String>(
        $InkLayersTable.$converteranchor.toSql(anchor),
      );
    }
    if (!nullToAbsent || spaceLines != null) {
      map['space_lines'] = Variable<int>(spaceLines);
    }
    map['collapsed'] = Variable<bool>(collapsed);
    map['strokes_b64'] = Variable<String>(strokesB64);
    map['stroke_count'] = Variable<int>(strokeCount);
    map['codec_version'] = Variable<int>(codecVersion);
    return map;
  }

  InkLayersCompanion toCompanion(bool nullToAbsent) {
    return InkLayersCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      versionHlc: Value(versionHlc),
      extras: extras == null && nullToAbsent
          ? const Value.absent()
          : Value(extras),
      id: Value(id),
      userId: Value(userId),
      userBookId: Value(userBookId),
      kind: Value(kind),
      anchor: Value(anchor),
      spaceLines: spaceLines == null && nullToAbsent
          ? const Value.absent()
          : Value(spaceLines),
      collapsed: Value(collapsed),
      strokesB64: Value(strokesB64),
      strokeCount: Value(strokeCount),
      codecVersion: Value(codecVersion),
    );
  }

  factory InkLayerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InkLayerRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      versionHlc: serializer.fromJson<Hlc>(json['versionHlc']),
      extras: serializer.fromJson<String?>(json['extras']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      userBookId: serializer.fromJson<String>(json['userBookId']),
      kind: serializer.fromJson<InkLayerKind>(json['kind']),
      anchor: serializer.fromJson<TextAnchor>(json['anchor']),
      spaceLines: serializer.fromJson<int?>(json['spaceLines']),
      collapsed: serializer.fromJson<bool>(json['collapsed']),
      strokesB64: serializer.fromJson<String>(json['strokesB64']),
      strokeCount: serializer.fromJson<int>(json['strokeCount']),
      codecVersion: serializer.fromJson<int>(json['codecVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'versionHlc': serializer.toJson<Hlc>(versionHlc),
      'extras': serializer.toJson<String?>(extras),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'userBookId': serializer.toJson<String>(userBookId),
      'kind': serializer.toJson<InkLayerKind>(kind),
      'anchor': serializer.toJson<TextAnchor>(anchor),
      'spaceLines': serializer.toJson<int?>(spaceLines),
      'collapsed': serializer.toJson<bool>(collapsed),
      'strokesB64': serializer.toJson<String>(strokesB64),
      'strokeCount': serializer.toJson<int>(strokeCount),
      'codecVersion': serializer.toJson<int>(codecVersion),
    };
  }

  InkLayerRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Hlc? versionHlc,
    Value<String?> extras = const Value.absent(),
    String? id,
    String? userId,
    String? userBookId,
    InkLayerKind? kind,
    TextAnchor? anchor,
    Value<int?> spaceLines = const Value.absent(),
    bool? collapsed,
    String? strokesB64,
    int? strokeCount,
    int? codecVersion,
  }) => InkLayerRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    versionHlc: versionHlc ?? this.versionHlc,
    extras: extras.present ? extras.value : this.extras,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    userBookId: userBookId ?? this.userBookId,
    kind: kind ?? this.kind,
    anchor: anchor ?? this.anchor,
    spaceLines: spaceLines.present ? spaceLines.value : this.spaceLines,
    collapsed: collapsed ?? this.collapsed,
    strokesB64: strokesB64 ?? this.strokesB64,
    strokeCount: strokeCount ?? this.strokeCount,
    codecVersion: codecVersion ?? this.codecVersion,
  );
  InkLayerRow copyWithCompanion(InkLayersCompanion data) {
    return InkLayerRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      versionHlc: data.versionHlc.present
          ? data.versionHlc.value
          : this.versionHlc,
      extras: data.extras.present ? data.extras.value : this.extras,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      userBookId: data.userBookId.present
          ? data.userBookId.value
          : this.userBookId,
      kind: data.kind.present ? data.kind.value : this.kind,
      anchor: data.anchor.present ? data.anchor.value : this.anchor,
      spaceLines: data.spaceLines.present
          ? data.spaceLines.value
          : this.spaceLines,
      collapsed: data.collapsed.present ? data.collapsed.value : this.collapsed,
      strokesB64: data.strokesB64.present
          ? data.strokesB64.value
          : this.strokesB64,
      strokeCount: data.strokeCount.present
          ? data.strokeCount.value
          : this.strokeCount,
      codecVersion: data.codecVersion.present
          ? data.codecVersion.value
          : this.codecVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InkLayerRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userBookId: $userBookId, ')
          ..write('kind: $kind, ')
          ..write('anchor: $anchor, ')
          ..write('spaceLines: $spaceLines, ')
          ..write('collapsed: $collapsed, ')
          ..write('strokesB64: $strokesB64, ')
          ..write('strokeCount: $strokeCount, ')
          ..write('codecVersion: $codecVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    userBookId,
    kind,
    anchor,
    spaceLines,
    collapsed,
    strokesB64,
    strokeCount,
    codecVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InkLayerRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.versionHlc == this.versionHlc &&
          other.extras == this.extras &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.userBookId == this.userBookId &&
          other.kind == this.kind &&
          other.anchor == this.anchor &&
          other.spaceLines == this.spaceLines &&
          other.collapsed == this.collapsed &&
          other.strokesB64 == this.strokesB64 &&
          other.strokeCount == this.strokeCount &&
          other.codecVersion == this.codecVersion);
}

class InkLayersCompanion extends UpdateCompanion<InkLayerRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<Hlc> versionHlc;
  final Value<String?> extras;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> userBookId;
  final Value<InkLayerKind> kind;
  final Value<TextAnchor> anchor;
  final Value<int?> spaceLines;
  final Value<bool> collapsed;
  final Value<String> strokesB64;
  final Value<int> strokeCount;
  final Value<int> codecVersion;
  final Value<int> rowid;
  const InkLayersCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.versionHlc = const Value.absent(),
    this.extras = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.userBookId = const Value.absent(),
    this.kind = const Value.absent(),
    this.anchor = const Value.absent(),
    this.spaceLines = const Value.absent(),
    this.collapsed = const Value.absent(),
    this.strokesB64 = const Value.absent(),
    this.strokeCount = const Value.absent(),
    this.codecVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InkLayersCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required Hlc versionHlc,
    this.extras = const Value.absent(),
    required String id,
    required String userId,
    required String userBookId,
    required InkLayerKind kind,
    required TextAnchor anchor,
    this.spaceLines = const Value.absent(),
    this.collapsed = const Value.absent(),
    required String strokesB64,
    required int strokeCount,
    this.codecVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       versionHlc = Value(versionHlc),
       id = Value(id),
       userId = Value(userId),
       userBookId = Value(userBookId),
       kind = Value(kind),
       anchor = Value(anchor),
       strokesB64 = Value(strokesB64),
       strokeCount = Value(strokeCount);
  static Insertable<InkLayerRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? versionHlc,
    Expression<String>? extras,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? userBookId,
    Expression<String>? kind,
    Expression<String>? anchor,
    Expression<int>? spaceLines,
    Expression<bool>? collapsed,
    Expression<String>? strokesB64,
    Expression<int>? strokeCount,
    Expression<int>? codecVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (versionHlc != null) 'version_hlc': versionHlc,
      if (extras != null) '_extras': extras,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (userBookId != null) 'user_book_id': userBookId,
      if (kind != null) 'kind': kind,
      if (anchor != null) 'anchor': anchor,
      if (spaceLines != null) 'space_lines': spaceLines,
      if (collapsed != null) 'collapsed': collapsed,
      if (strokesB64 != null) 'strokes_b64': strokesB64,
      if (strokeCount != null) 'stroke_count': strokeCount,
      if (codecVersion != null) 'codec_version': codecVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InkLayersCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<Hlc>? versionHlc,
    Value<String?>? extras,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? userBookId,
    Value<InkLayerKind>? kind,
    Value<TextAnchor>? anchor,
    Value<int?>? spaceLines,
    Value<bool>? collapsed,
    Value<String>? strokesB64,
    Value<int>? strokeCount,
    Value<int>? codecVersion,
    Value<int>? rowid,
  }) {
    return InkLayersCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      versionHlc: versionHlc ?? this.versionHlc,
      extras: extras ?? this.extras,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userBookId: userBookId ?? this.userBookId,
      kind: kind ?? this.kind,
      anchor: anchor ?? this.anchor,
      spaceLines: spaceLines ?? this.spaceLines,
      collapsed: collapsed ?? this.collapsed,
      strokesB64: strokesB64 ?? this.strokesB64,
      strokeCount: strokeCount ?? this.strokeCount,
      codecVersion: codecVersion ?? this.codecVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $InkLayersTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $InkLayersTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $InkLayersTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (versionHlc.present) {
      map['version_hlc'] = Variable<String>(
        $InkLayersTable.$converterversionHlc.toSql(versionHlc.value),
      );
    }
    if (extras.present) {
      map['_extras'] = Variable<String>(extras.value);
    }
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
      map['kind'] = Variable<String>(
        $InkLayersTable.$converterkind.toSql(kind.value),
      );
    }
    if (anchor.present) {
      map['anchor'] = Variable<String>(
        $InkLayersTable.$converteranchor.toSql(anchor.value),
      );
    }
    if (spaceLines.present) {
      map['space_lines'] = Variable<int>(spaceLines.value);
    }
    if (collapsed.present) {
      map['collapsed'] = Variable<bool>(collapsed.value);
    }
    if (strokesB64.present) {
      map['strokes_b64'] = Variable<String>(strokesB64.value);
    }
    if (strokeCount.present) {
      map['stroke_count'] = Variable<int>(strokeCount.value);
    }
    if (codecVersion.present) {
      map['codec_version'] = Variable<int>(codecVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InkLayersCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userBookId: $userBookId, ')
          ..write('kind: $kind, ')
          ..write('anchor: $anchor, ')
          ..write('spaceLines: $spaceLines, ')
          ..write('collapsed: $collapsed, ')
          ..write('strokesB64: $strokesB64, ')
          ..write('strokeCount: $strokeCount, ')
          ..write('codecVersion: $codecVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnnotationsTable extends Annotations
    with TableInfo<$AnnotationsTable, AnnotationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnnotationsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($AnnotationsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($AnnotationsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($AnnotationsTable.$converterdeletedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> versionHlc =
      GeneratedColumn<String>(
        'version_hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($AnnotationsTable.$converterversionHlc);
  static const VerificationMeta _extrasMeta = const VerificationMeta('extras');
  @override
  late final GeneratedColumn<String> extras = GeneratedColumn<String>(
    '_extras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  @override
  late final GeneratedColumnWithTypeConverter<AnnotationKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AnnotationKind>($AnnotationsTable.$converterkind);
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
  @override
  late final GeneratedColumnWithTypeConverter<AnnotationSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('selection'),
      ).withConverter<AnnotationSource>($AnnotationsTable.$convertersource);
  @override
  late final GeneratedColumnWithTypeConverter<TextAnchor, String> anchor =
      GeneratedColumn<String>(
        'anchor',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TextAnchor>($AnnotationsTable.$converteranchor);
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
  @override
  late final GeneratedColumnWithTypeConverter<HighlightStyle?, String> style =
      GeneratedColumn<String>(
        'style',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<HighlightStyle?>($AnnotationsTable.$converterstylen);
  @override
  late final GeneratedColumnWithTypeConverter<FillHeight?, String> fillHeight =
      GeneratedColumn<String>(
        'fill_height',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<FillHeight?>($AnnotationsTable.$converterfillHeightn);
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
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
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
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'annotations';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnnotationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('_extras')) {
      context.handle(
        _extrasMeta,
        extras.isAcceptableOrUnknown(data['_extras']!, _extrasMeta),
      );
    }
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnnotationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnnotationRow(
      createdAt: $AnnotationsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $AnnotationsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $AnnotationsTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      versionHlc: $AnnotationsTable.$converterversionHlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}version_hlc'],
        )!,
      ),
      extras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}_extras'],
      ),
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
      kind: $AnnotationsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      source: $AnnotationsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      anchor: $AnnotationsTable.$converteranchor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}anchor'],
        )!,
      ),
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
      style: $AnnotationsTable.$converterstylen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}style'],
        ),
      ),
      fillHeight: $AnnotationsTable.$converterfillHeightn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fill_height'],
        ),
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
    );
  }

  @override
  $AnnotationsTable createAlias(String alias) {
    return $AnnotationsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const InstantConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<Hlc, String> $converterversionHlc = const HlcConverter();
  static TypeConverter<AnnotationKind, String> $converterkind =
      const CodeConverter(AnnotationKind.fromCode);
  static TypeConverter<AnnotationSource, String> $convertersource =
      const CodeConverter(AnnotationSource.fromCode);
  static TypeConverter<TextAnchor, String> $converteranchor =
      const AnchorConverter();
  static TypeConverter<HighlightStyle, String> $converterstyle =
      const CodeConverter(HighlightStyle.fromCode);
  static TypeConverter<HighlightStyle?, String?> $converterstylen =
      NullAwareTypeConverter.wrap($converterstyle);
  static TypeConverter<FillHeight, String> $converterfillHeight =
      const CodeConverter(FillHeight.fromCode);
  static TypeConverter<FillHeight?, String?> $converterfillHeightn =
      NullAwareTypeConverter.wrap($converterfillHeight);
  @override
  bool get isStrict => true;
}

class AnnotationRow extends DataClass implements Insertable<AnnotationRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Hlc versionHlc;

  /// Colunas do servidor ainda desconhecidas por esta versão (parâmetro "Rest" do `put`).
  final String? extras;
  final String id;
  final String userId;
  final String userBookId;
  final AnnotationKind kind;
  final String? parentId;
  final String groupId;
  final AnnotationSource source;
  final TextAnchor anchor;
  final int refPage;
  final int chapterIndex;
  final String? color;
  final HighlightStyle? style;
  final FillHeight? fillHeight;
  final String? noteText;
  final String? inkLayerId;
  final String? sharedClubPostId;
  const AnnotationRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.versionHlc,
    this.extras,
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
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['created_at'] = Variable<String>(
        $AnnotationsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $AnnotationsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $AnnotationsTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    {
      map['version_hlc'] = Variable<String>(
        $AnnotationsTable.$converterversionHlc.toSql(versionHlc),
      );
    }
    if (!nullToAbsent || extras != null) {
      map['_extras'] = Variable<String>(extras);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['user_book_id'] = Variable<String>(userBookId);
    {
      map['kind'] = Variable<String>(
        $AnnotationsTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['group_id'] = Variable<String>(groupId);
    {
      map['source'] = Variable<String>(
        $AnnotationsTable.$convertersource.toSql(source),
      );
    }
    {
      map['anchor'] = Variable<String>(
        $AnnotationsTable.$converteranchor.toSql(anchor),
      );
    }
    map['ref_page'] = Variable<int>(refPage);
    map['chapter_index'] = Variable<int>(chapterIndex);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || style != null) {
      map['style'] = Variable<String>(
        $AnnotationsTable.$converterstylen.toSql(style),
      );
    }
    if (!nullToAbsent || fillHeight != null) {
      map['fill_height'] = Variable<String>(
        $AnnotationsTable.$converterfillHeightn.toSql(fillHeight),
      );
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
    return map;
  }

  AnnotationsCompanion toCompanion(bool nullToAbsent) {
    return AnnotationsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      versionHlc: Value(versionHlc),
      extras: extras == null && nullToAbsent
          ? const Value.absent()
          : Value(extras),
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
    );
  }

  factory AnnotationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnnotationRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      versionHlc: serializer.fromJson<Hlc>(json['versionHlc']),
      extras: serializer.fromJson<String?>(json['extras']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      userBookId: serializer.fromJson<String>(json['userBookId']),
      kind: serializer.fromJson<AnnotationKind>(json['kind']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      groupId: serializer.fromJson<String>(json['groupId']),
      source: serializer.fromJson<AnnotationSource>(json['source']),
      anchor: serializer.fromJson<TextAnchor>(json['anchor']),
      refPage: serializer.fromJson<int>(json['refPage']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      color: serializer.fromJson<String?>(json['color']),
      style: serializer.fromJson<HighlightStyle?>(json['style']),
      fillHeight: serializer.fromJson<FillHeight?>(json['fillHeight']),
      noteText: serializer.fromJson<String?>(json['noteText']),
      inkLayerId: serializer.fromJson<String?>(json['inkLayerId']),
      sharedClubPostId: serializer.fromJson<String?>(json['sharedClubPostId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'versionHlc': serializer.toJson<Hlc>(versionHlc),
      'extras': serializer.toJson<String?>(extras),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'userBookId': serializer.toJson<String>(userBookId),
      'kind': serializer.toJson<AnnotationKind>(kind),
      'parentId': serializer.toJson<String?>(parentId),
      'groupId': serializer.toJson<String>(groupId),
      'source': serializer.toJson<AnnotationSource>(source),
      'anchor': serializer.toJson<TextAnchor>(anchor),
      'refPage': serializer.toJson<int>(refPage),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'color': serializer.toJson<String?>(color),
      'style': serializer.toJson<HighlightStyle?>(style),
      'fillHeight': serializer.toJson<FillHeight?>(fillHeight),
      'noteText': serializer.toJson<String?>(noteText),
      'inkLayerId': serializer.toJson<String?>(inkLayerId),
      'sharedClubPostId': serializer.toJson<String?>(sharedClubPostId),
    };
  }

  AnnotationRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Hlc? versionHlc,
    Value<String?> extras = const Value.absent(),
    String? id,
    String? userId,
    String? userBookId,
    AnnotationKind? kind,
    Value<String?> parentId = const Value.absent(),
    String? groupId,
    AnnotationSource? source,
    TextAnchor? anchor,
    int? refPage,
    int? chapterIndex,
    Value<String?> color = const Value.absent(),
    Value<HighlightStyle?> style = const Value.absent(),
    Value<FillHeight?> fillHeight = const Value.absent(),
    Value<String?> noteText = const Value.absent(),
    Value<String?> inkLayerId = const Value.absent(),
    Value<String?> sharedClubPostId = const Value.absent(),
  }) => AnnotationRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    versionHlc: versionHlc ?? this.versionHlc,
    extras: extras.present ? extras.value : this.extras,
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
  );
  AnnotationRow copyWithCompanion(AnnotationsCompanion data) {
    return AnnotationRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      versionHlc: data.versionHlc.present
          ? data.versionHlc.value
          : this.versionHlc,
      extras: data.extras.present ? data.extras.value : this.extras,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnnotationRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
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
          ..write('sharedClubPostId: $sharedClubPostId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
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
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnnotationRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.versionHlc == this.versionHlc &&
          other.extras == this.extras &&
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
          other.sharedClubPostId == this.sharedClubPostId);
}

class AnnotationsCompanion extends UpdateCompanion<AnnotationRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<Hlc> versionHlc;
  final Value<String?> extras;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> userBookId;
  final Value<AnnotationKind> kind;
  final Value<String?> parentId;
  final Value<String> groupId;
  final Value<AnnotationSource> source;
  final Value<TextAnchor> anchor;
  final Value<int> refPage;
  final Value<int> chapterIndex;
  final Value<String?> color;
  final Value<HighlightStyle?> style;
  final Value<FillHeight?> fillHeight;
  final Value<String?> noteText;
  final Value<String?> inkLayerId;
  final Value<String?> sharedClubPostId;
  final Value<int> rowid;
  const AnnotationsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.versionHlc = const Value.absent(),
    this.extras = const Value.absent(),
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
    this.rowid = const Value.absent(),
  });
  AnnotationsCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required Hlc versionHlc,
    this.extras = const Value.absent(),
    required String id,
    required String userId,
    required String userBookId,
    required AnnotationKind kind,
    this.parentId = const Value.absent(),
    required String groupId,
    this.source = const Value.absent(),
    required TextAnchor anchor,
    required int refPage,
    required int chapterIndex,
    this.color = const Value.absent(),
    this.style = const Value.absent(),
    this.fillHeight = const Value.absent(),
    this.noteText = const Value.absent(),
    this.inkLayerId = const Value.absent(),
    this.sharedClubPostId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       versionHlc = Value(versionHlc),
       id = Value(id),
       userId = Value(userId),
       userBookId = Value(userBookId),
       kind = Value(kind),
       groupId = Value(groupId),
       anchor = Value(anchor),
       refPage = Value(refPage),
       chapterIndex = Value(chapterIndex);
  static Insertable<AnnotationRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? versionHlc,
    Expression<String>? extras,
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
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (versionHlc != null) 'version_hlc': versionHlc,
      if (extras != null) '_extras': extras,
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
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnnotationsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<Hlc>? versionHlc,
    Value<String?>? extras,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? userBookId,
    Value<AnnotationKind>? kind,
    Value<String?>? parentId,
    Value<String>? groupId,
    Value<AnnotationSource>? source,
    Value<TextAnchor>? anchor,
    Value<int>? refPage,
    Value<int>? chapterIndex,
    Value<String?>? color,
    Value<HighlightStyle?>? style,
    Value<FillHeight?>? fillHeight,
    Value<String?>? noteText,
    Value<String?>? inkLayerId,
    Value<String?>? sharedClubPostId,
    Value<int>? rowid,
  }) {
    return AnnotationsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      versionHlc: versionHlc ?? this.versionHlc,
      extras: extras ?? this.extras,
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $AnnotationsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $AnnotationsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $AnnotationsTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (versionHlc.present) {
      map['version_hlc'] = Variable<String>(
        $AnnotationsTable.$converterversionHlc.toSql(versionHlc.value),
      );
    }
    if (extras.present) {
      map['_extras'] = Variable<String>(extras.value);
    }
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
      map['kind'] = Variable<String>(
        $AnnotationsTable.$converterkind.toSql(kind.value),
      );
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $AnnotationsTable.$convertersource.toSql(source.value),
      );
    }
    if (anchor.present) {
      map['anchor'] = Variable<String>(
        $AnnotationsTable.$converteranchor.toSql(anchor.value),
      );
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
      map['style'] = Variable<String>(
        $AnnotationsTable.$converterstylen.toSql(style.value),
      );
    }
    if (fillHeight.present) {
      map['fill_height'] = Variable<String>(
        $AnnotationsTable.$converterfillHeightn.toSql(fillHeight.value),
      );
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnnotationsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
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
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HighlightLabelsTable extends HighlightLabels
    with TableInfo<$HighlightLabelsTable, HighlightLabelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HighlightLabelsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($HighlightLabelsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($HighlightLabelsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($HighlightLabelsTable.$converterdeletedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> versionHlc =
      GeneratedColumn<String>(
        'version_hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($HighlightLabelsTable.$converterversionHlc);
  static const VerificationMeta _extrasMeta = const VerificationMeta('extras');
  @override
  late final GeneratedColumn<String> extras = GeneratedColumn<String>(
    '_extras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    color,
    label,
    sort,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'highlight_labels';
  @override
  VerificationContext validateIntegrity(
    Insertable<HighlightLabelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('_extras')) {
      context.handle(
        _extrasMeta,
        extras.isAcceptableOrUnknown(data['_extras']!, _extrasMeta),
      );
    }
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
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('sort')) {
      context.handle(
        _sortMeta,
        sort.isAcceptableOrUnknown(data['sort']!, _sortMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HighlightLabelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HighlightLabelRow(
      createdAt: $HighlightLabelsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $HighlightLabelsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $HighlightLabelsTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      versionHlc: $HighlightLabelsTable.$converterversionHlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}version_hlc'],
        )!,
      ),
      extras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}_extras'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      sort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort'],
      )!,
    );
  }

  @override
  $HighlightLabelsTable createAlias(String alias) {
    return $HighlightLabelsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const InstantConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<Hlc, String> $converterversionHlc = const HlcConverter();
  @override
  bool get isStrict => true;
}

class HighlightLabelRow extends DataClass
    implements Insertable<HighlightLabelRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Hlc versionHlc;

  /// Colunas do servidor ainda desconhecidas por esta versão (parâmetro "Rest" do `put`).
  final String? extras;
  final String id;
  final String userId;
  final String color;
  final String label;
  final int sort;
  const HighlightLabelRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.versionHlc,
    this.extras,
    required this.id,
    required this.userId,
    required this.color,
    required this.label,
    required this.sort,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['created_at'] = Variable<String>(
        $HighlightLabelsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $HighlightLabelsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $HighlightLabelsTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    {
      map['version_hlc'] = Variable<String>(
        $HighlightLabelsTable.$converterversionHlc.toSql(versionHlc),
      );
    }
    if (!nullToAbsent || extras != null) {
      map['_extras'] = Variable<String>(extras);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['color'] = Variable<String>(color);
    map['label'] = Variable<String>(label);
    map['sort'] = Variable<int>(sort);
    return map;
  }

  HighlightLabelsCompanion toCompanion(bool nullToAbsent) {
    return HighlightLabelsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      versionHlc: Value(versionHlc),
      extras: extras == null && nullToAbsent
          ? const Value.absent()
          : Value(extras),
      id: Value(id),
      userId: Value(userId),
      color: Value(color),
      label: Value(label),
      sort: Value(sort),
    );
  }

  factory HighlightLabelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HighlightLabelRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      versionHlc: serializer.fromJson<Hlc>(json['versionHlc']),
      extras: serializer.fromJson<String?>(json['extras']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      color: serializer.fromJson<String>(json['color']),
      label: serializer.fromJson<String>(json['label']),
      sort: serializer.fromJson<int>(json['sort']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'versionHlc': serializer.toJson<Hlc>(versionHlc),
      'extras': serializer.toJson<String?>(extras),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'color': serializer.toJson<String>(color),
      'label': serializer.toJson<String>(label),
      'sort': serializer.toJson<int>(sort),
    };
  }

  HighlightLabelRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Hlc? versionHlc,
    Value<String?> extras = const Value.absent(),
    String? id,
    String? userId,
    String? color,
    String? label,
    int? sort,
  }) => HighlightLabelRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    versionHlc: versionHlc ?? this.versionHlc,
    extras: extras.present ? extras.value : this.extras,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    color: color ?? this.color,
    label: label ?? this.label,
    sort: sort ?? this.sort,
  );
  HighlightLabelRow copyWithCompanion(HighlightLabelsCompanion data) {
    return HighlightLabelRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      versionHlc: data.versionHlc.present
          ? data.versionHlc.value
          : this.versionHlc,
      extras: data.extras.present ? data.extras.value : this.extras,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      color: data.color.present ? data.color.value : this.color,
      label: data.label.present ? data.label.value : this.label,
      sort: data.sort.present ? data.sort.value : this.sort,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HighlightLabelRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('color: $color, ')
          ..write('label: $label, ')
          ..write('sort: $sort')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    color,
    label,
    sort,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HighlightLabelRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.versionHlc == this.versionHlc &&
          other.extras == this.extras &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.color == this.color &&
          other.label == this.label &&
          other.sort == this.sort);
}

class HighlightLabelsCompanion extends UpdateCompanion<HighlightLabelRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<Hlc> versionHlc;
  final Value<String?> extras;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> color;
  final Value<String> label;
  final Value<int> sort;
  final Value<int> rowid;
  const HighlightLabelsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.versionHlc = const Value.absent(),
    this.extras = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.color = const Value.absent(),
    this.label = const Value.absent(),
    this.sort = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HighlightLabelsCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required Hlc versionHlc,
    this.extras = const Value.absent(),
    required String id,
    required String userId,
    required String color,
    required String label,
    this.sort = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       versionHlc = Value(versionHlc),
       id = Value(id),
       userId = Value(userId),
       color = Value(color),
       label = Value(label);
  static Insertable<HighlightLabelRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? versionHlc,
    Expression<String>? extras,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? color,
    Expression<String>? label,
    Expression<int>? sort,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (versionHlc != null) 'version_hlc': versionHlc,
      if (extras != null) '_extras': extras,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (color != null) 'color': color,
      if (label != null) 'label': label,
      if (sort != null) 'sort': sort,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HighlightLabelsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<Hlc>? versionHlc,
    Value<String?>? extras,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? color,
    Value<String>? label,
    Value<int>? sort,
    Value<int>? rowid,
  }) {
    return HighlightLabelsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      versionHlc: versionHlc ?? this.versionHlc,
      extras: extras ?? this.extras,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      color: color ?? this.color,
      label: label ?? this.label,
      sort: sort ?? this.sort,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $HighlightLabelsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $HighlightLabelsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $HighlightLabelsTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (versionHlc.present) {
      map['version_hlc'] = Variable<String>(
        $HighlightLabelsTable.$converterversionHlc.toSql(versionHlc.value),
      );
    }
    if (extras.present) {
      map['_extras'] = Variable<String>(extras.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HighlightLabelsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('color: $color, ')
          ..write('label: $label, ')
          ..write('sort: $sort, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReaderSettingsRowsTable extends ReaderSettingsRows
    with TableInfo<$ReaderSettingsRowsTable, ReaderSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReaderSettingsRowsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReaderSettingsRowsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReaderSettingsRowsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ReaderSettingsRowsTable.$converterdeletedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> versionHlc =
      GeneratedColumn<String>(
        'version_hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($ReaderSettingsRowsTable.$converterversionHlc);
  static const VerificationMeta _extrasMeta = const VerificationMeta('extras');
  @override
  late final GeneratedColumn<String> extras = GeneratedColumn<String>(
    '_extras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  static const VerificationMeta _fontStepMeta = const VerificationMeta(
    'fontStep',
  );
  @override
  late final GeneratedColumn<int> fontStep = GeneratedColumn<int>(
    'font_step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReaderFontFamily, String>
  fontFamily =
      GeneratedColumn<String>(
        'font_family',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('literata'),
      ).withConverter<ReaderFontFamily>(
        $ReaderSettingsRowsTable.$converterfontFamily,
      );
  @override
  late final GeneratedColumnWithTypeConverter<ReaderPaper, String> paper =
      GeneratedColumn<String>(
        'paper',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('creme'),
      ).withConverter<ReaderPaper>($ReaderSettingsRowsTable.$converterpaper);
  @override
  late final GeneratedColumnWithTypeConverter<ReaderLineSpacing, String>
  lineSpacing =
      GeneratedColumn<String>(
        'line_spacing',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('medio'),
      ).withConverter<ReaderLineSpacing>(
        $ReaderSettingsRowsTable.$converterlineSpacing,
      );
  @override
  late final GeneratedColumnWithTypeConverter<ReaderMargins, String> margins =
      GeneratedColumn<String>(
        'margins',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('media'),
      ).withConverter<ReaderMargins>(
        $ReaderSettingsRowsTable.$convertermargins,
      );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    fontStep,
    fontFamily,
    paper,
    lineSpacing,
    margins,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reader_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReaderSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('_extras')) {
      context.handle(
        _extrasMeta,
        extras.isAcceptableOrUnknown(data['_extras']!, _extrasMeta),
      );
    }
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
    if (data.containsKey('font_step')) {
      context.handle(
        _fontStepMeta,
        fontStep.isAcceptableOrUnknown(data['font_step']!, _fontStepMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReaderSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReaderSettingsRow(
      createdAt: $ReaderSettingsRowsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $ReaderSettingsRowsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $ReaderSettingsRowsTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      versionHlc: $ReaderSettingsRowsTable.$converterversionHlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}version_hlc'],
        )!,
      ),
      extras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}_extras'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      fontStep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}font_step'],
      )!,
      fontFamily: $ReaderSettingsRowsTable.$converterfontFamily.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}font_family'],
        )!,
      ),
      paper: $ReaderSettingsRowsTable.$converterpaper.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}paper'],
        )!,
      ),
      lineSpacing: $ReaderSettingsRowsTable.$converterlineSpacing.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}line_spacing'],
        )!,
      ),
      margins: $ReaderSettingsRowsTable.$convertermargins.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}margins'],
        )!,
      ),
    );
  }

  @override
  $ReaderSettingsRowsTable createAlias(String alias) {
    return $ReaderSettingsRowsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const InstantConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<Hlc, String> $converterversionHlc = const HlcConverter();
  static TypeConverter<ReaderFontFamily, String> $converterfontFamily =
      const CodeConverter(ReaderFontFamily.fromCode);
  static TypeConverter<ReaderPaper, String> $converterpaper =
      const CodeConverter(ReaderPaper.fromCode);
  static TypeConverter<ReaderLineSpacing, String> $converterlineSpacing =
      const CodeConverter(ReaderLineSpacing.fromCode);
  static TypeConverter<ReaderMargins, String> $convertermargins =
      const CodeConverter(ReaderMargins.fromCode);
  @override
  bool get isStrict => true;
}

class ReaderSettingsRow extends DataClass
    implements Insertable<ReaderSettingsRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Hlc versionHlc;

  /// Colunas do servidor ainda desconhecidas por esta versão (parâmetro "Rest" do `put`).
  final String? extras;
  final String id;
  final String userId;
  final int fontStep;
  final ReaderFontFamily fontFamily;
  final ReaderPaper paper;
  final ReaderLineSpacing lineSpacing;
  final ReaderMargins margins;
  const ReaderSettingsRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.versionHlc,
    this.extras,
    required this.id,
    required this.userId,
    required this.fontStep,
    required this.fontFamily,
    required this.paper,
    required this.lineSpacing,
    required this.margins,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['created_at'] = Variable<String>(
        $ReaderSettingsRowsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $ReaderSettingsRowsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $ReaderSettingsRowsTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    {
      map['version_hlc'] = Variable<String>(
        $ReaderSettingsRowsTable.$converterversionHlc.toSql(versionHlc),
      );
    }
    if (!nullToAbsent || extras != null) {
      map['_extras'] = Variable<String>(extras);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['font_step'] = Variable<int>(fontStep);
    {
      map['font_family'] = Variable<String>(
        $ReaderSettingsRowsTable.$converterfontFamily.toSql(fontFamily),
      );
    }
    {
      map['paper'] = Variable<String>(
        $ReaderSettingsRowsTable.$converterpaper.toSql(paper),
      );
    }
    {
      map['line_spacing'] = Variable<String>(
        $ReaderSettingsRowsTable.$converterlineSpacing.toSql(lineSpacing),
      );
    }
    {
      map['margins'] = Variable<String>(
        $ReaderSettingsRowsTable.$convertermargins.toSql(margins),
      );
    }
    return map;
  }

  ReaderSettingsRowsCompanion toCompanion(bool nullToAbsent) {
    return ReaderSettingsRowsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      versionHlc: Value(versionHlc),
      extras: extras == null && nullToAbsent
          ? const Value.absent()
          : Value(extras),
      id: Value(id),
      userId: Value(userId),
      fontStep: Value(fontStep),
      fontFamily: Value(fontFamily),
      paper: Value(paper),
      lineSpacing: Value(lineSpacing),
      margins: Value(margins),
    );
  }

  factory ReaderSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReaderSettingsRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      versionHlc: serializer.fromJson<Hlc>(json['versionHlc']),
      extras: serializer.fromJson<String?>(json['extras']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      fontStep: serializer.fromJson<int>(json['fontStep']),
      fontFamily: serializer.fromJson<ReaderFontFamily>(json['fontFamily']),
      paper: serializer.fromJson<ReaderPaper>(json['paper']),
      lineSpacing: serializer.fromJson<ReaderLineSpacing>(json['lineSpacing']),
      margins: serializer.fromJson<ReaderMargins>(json['margins']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'versionHlc': serializer.toJson<Hlc>(versionHlc),
      'extras': serializer.toJson<String?>(extras),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'fontStep': serializer.toJson<int>(fontStep),
      'fontFamily': serializer.toJson<ReaderFontFamily>(fontFamily),
      'paper': serializer.toJson<ReaderPaper>(paper),
      'lineSpacing': serializer.toJson<ReaderLineSpacing>(lineSpacing),
      'margins': serializer.toJson<ReaderMargins>(margins),
    };
  }

  ReaderSettingsRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Hlc? versionHlc,
    Value<String?> extras = const Value.absent(),
    String? id,
    String? userId,
    int? fontStep,
    ReaderFontFamily? fontFamily,
    ReaderPaper? paper,
    ReaderLineSpacing? lineSpacing,
    ReaderMargins? margins,
  }) => ReaderSettingsRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    versionHlc: versionHlc ?? this.versionHlc,
    extras: extras.present ? extras.value : this.extras,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    fontStep: fontStep ?? this.fontStep,
    fontFamily: fontFamily ?? this.fontFamily,
    paper: paper ?? this.paper,
    lineSpacing: lineSpacing ?? this.lineSpacing,
    margins: margins ?? this.margins,
  );
  ReaderSettingsRow copyWithCompanion(ReaderSettingsRowsCompanion data) {
    return ReaderSettingsRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      versionHlc: data.versionHlc.present
          ? data.versionHlc.value
          : this.versionHlc,
      extras: data.extras.present ? data.extras.value : this.extras,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      fontStep: data.fontStep.present ? data.fontStep.value : this.fontStep,
      fontFamily: data.fontFamily.present
          ? data.fontFamily.value
          : this.fontFamily,
      paper: data.paper.present ? data.paper.value : this.paper,
      lineSpacing: data.lineSpacing.present
          ? data.lineSpacing.value
          : this.lineSpacing,
      margins: data.margins.present ? data.margins.value : this.margins,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReaderSettingsRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('fontStep: $fontStep, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('paper: $paper, ')
          ..write('lineSpacing: $lineSpacing, ')
          ..write('margins: $margins')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    fontStep,
    fontFamily,
    paper,
    lineSpacing,
    margins,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReaderSettingsRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.versionHlc == this.versionHlc &&
          other.extras == this.extras &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.fontStep == this.fontStep &&
          other.fontFamily == this.fontFamily &&
          other.paper == this.paper &&
          other.lineSpacing == this.lineSpacing &&
          other.margins == this.margins);
}

class ReaderSettingsRowsCompanion extends UpdateCompanion<ReaderSettingsRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<Hlc> versionHlc;
  final Value<String?> extras;
  final Value<String> id;
  final Value<String> userId;
  final Value<int> fontStep;
  final Value<ReaderFontFamily> fontFamily;
  final Value<ReaderPaper> paper;
  final Value<ReaderLineSpacing> lineSpacing;
  final Value<ReaderMargins> margins;
  final Value<int> rowid;
  const ReaderSettingsRowsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.versionHlc = const Value.absent(),
    this.extras = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.fontStep = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.paper = const Value.absent(),
    this.lineSpacing = const Value.absent(),
    this.margins = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReaderSettingsRowsCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required Hlc versionHlc,
    this.extras = const Value.absent(),
    required String id,
    required String userId,
    this.fontStep = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.paper = const Value.absent(),
    this.lineSpacing = const Value.absent(),
    this.margins = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       versionHlc = Value(versionHlc),
       id = Value(id),
       userId = Value(userId);
  static Insertable<ReaderSettingsRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? versionHlc,
    Expression<String>? extras,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? fontStep,
    Expression<String>? fontFamily,
    Expression<String>? paper,
    Expression<String>? lineSpacing,
    Expression<String>? margins,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (versionHlc != null) 'version_hlc': versionHlc,
      if (extras != null) '_extras': extras,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (fontStep != null) 'font_step': fontStep,
      if (fontFamily != null) 'font_family': fontFamily,
      if (paper != null) 'paper': paper,
      if (lineSpacing != null) 'line_spacing': lineSpacing,
      if (margins != null) 'margins': margins,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReaderSettingsRowsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<Hlc>? versionHlc,
    Value<String?>? extras,
    Value<String>? id,
    Value<String>? userId,
    Value<int>? fontStep,
    Value<ReaderFontFamily>? fontFamily,
    Value<ReaderPaper>? paper,
    Value<ReaderLineSpacing>? lineSpacing,
    Value<ReaderMargins>? margins,
    Value<int>? rowid,
  }) {
    return ReaderSettingsRowsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      versionHlc: versionHlc ?? this.versionHlc,
      extras: extras ?? this.extras,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fontStep: fontStep ?? this.fontStep,
      fontFamily: fontFamily ?? this.fontFamily,
      paper: paper ?? this.paper,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      margins: margins ?? this.margins,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $ReaderSettingsRowsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $ReaderSettingsRowsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $ReaderSettingsRowsTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (versionHlc.present) {
      map['version_hlc'] = Variable<String>(
        $ReaderSettingsRowsTable.$converterversionHlc.toSql(versionHlc.value),
      );
    }
    if (extras.present) {
      map['_extras'] = Variable<String>(extras.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (fontStep.present) {
      map['font_step'] = Variable<int>(fontStep.value);
    }
    if (fontFamily.present) {
      map['font_family'] = Variable<String>(
        $ReaderSettingsRowsTable.$converterfontFamily.toSql(fontFamily.value),
      );
    }
    if (paper.present) {
      map['paper'] = Variable<String>(
        $ReaderSettingsRowsTable.$converterpaper.toSql(paper.value),
      );
    }
    if (lineSpacing.present) {
      map['line_spacing'] = Variable<String>(
        $ReaderSettingsRowsTable.$converterlineSpacing.toSql(lineSpacing.value),
      );
    }
    if (margins.present) {
      map['margins'] = Variable<String>(
        $ReaderSettingsRowsTable.$convertermargins.toSql(margins.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReaderSettingsRowsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('fontStep: $fontStep, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('paper: $paper, ')
          ..write('lineSpacing: $lineSpacing, ')
          ..write('margins: $margins, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PenPresetsRowsTable extends PenPresetsRows
    with TableInfo<$PenPresetsRowsTable, PenPresetsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PenPresetsRowsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PenPresetsRowsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PenPresetsRowsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($PenPresetsRowsTable.$converterdeletedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> versionHlc =
      GeneratedColumn<String>(
        'version_hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($PenPresetsRowsTable.$converterversionHlc);
  static const VerificationMeta _extrasMeta = const VerificationMeta('extras');
  @override
  late final GeneratedColumn<String> extras = GeneratedColumn<String>(
    '_extras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  @override
  late final GeneratedColumnWithTypeConverter<PenTip, String> penTip =
      GeneratedColumn<String>(
        'pen_tip',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('ballpoint'),
      ).withConverter<PenTip>($PenPresetsRowsTable.$converterpenTip);
  @override
  late final GeneratedColumnWithTypeConverter<double, String> penWidthMm =
      GeneratedColumn<String>(
        'pen_width_mm',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('1.2'),
      ).withConverter<double>($PenPresetsRowsTable.$converterpenWidthMm);
  static const VerificationMeta _penColorMeta = const VerificationMeta(
    'penColor',
  );
  @override
  late final GeneratedColumn<String> penColor = GeneratedColumn<String>(
    'pen_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#FF552E'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  favoriteColors = GeneratedColumn<String>(
    'favorite_colors',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(
      '["#FF552E","#552CB7","#058CD7","#00995E","#F2A815","#1A1714"]',
    ),
  ).withConverter<List<String>>($PenPresetsRowsTable.$converterfavoriteColors);
  @override
  late final GeneratedColumnWithTypeConverter<StrokeSize, String> strokeSize =
      GeneratedColumn<String>(
        'stroke_size',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('medium'),
      ).withConverter<StrokeSize>($PenPresetsRowsTable.$converterstrokeSize);
  @override
  late final GeneratedColumnWithTypeConverter<HighlightStyle, String>
  highlighterStyle =
      GeneratedColumn<String>(
        'highlighter_style',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('fill'),
      ).withConverter<HighlightStyle>(
        $PenPresetsRowsTable.$converterhighlighterStyle,
      );
  @override
  late final GeneratedColumnWithTypeConverter<FillHeight, String>
  highlighterHeight = GeneratedColumn<String>(
    'highlighter_height',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  ).withConverter<FillHeight>($PenPresetsRowsTable.$converterhighlighterHeight);
  static const VerificationMeta _highlighterColorMeta = const VerificationMeta(
    'highlighterColor',
  );
  @override
  late final GeneratedColumn<String> highlighterColor = GeneratedColumn<String>(
    'highlighter_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#FED170'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    penTip,
    penWidthMm,
    penColor,
    favoriteColors,
    strokeSize,
    highlighterStyle,
    highlighterHeight,
    highlighterColor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pen_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<PenPresetsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('_extras')) {
      context.handle(
        _extrasMeta,
        extras.isAcceptableOrUnknown(data['_extras']!, _extrasMeta),
      );
    }
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
    if (data.containsKey('pen_color')) {
      context.handle(
        _penColorMeta,
        penColor.isAcceptableOrUnknown(data['pen_color']!, _penColorMeta),
      );
    }
    if (data.containsKey('highlighter_color')) {
      context.handle(
        _highlighterColorMeta,
        highlighterColor.isAcceptableOrUnknown(
          data['highlighter_color']!,
          _highlighterColorMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PenPresetsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PenPresetsRow(
      createdAt: $PenPresetsRowsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $PenPresetsRowsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $PenPresetsRowsTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      versionHlc: $PenPresetsRowsTable.$converterversionHlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}version_hlc'],
        )!,
      ),
      extras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}_extras'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      penTip: $PenPresetsRowsTable.$converterpenTip.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}pen_tip'],
        )!,
      ),
      penWidthMm: $PenPresetsRowsTable.$converterpenWidthMm.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}pen_width_mm'],
        )!,
      ),
      penColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pen_color'],
      )!,
      favoriteColors: $PenPresetsRowsTable.$converterfavoriteColors.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}favorite_colors'],
        )!,
      ),
      strokeSize: $PenPresetsRowsTable.$converterstrokeSize.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}stroke_size'],
        )!,
      ),
      highlighterStyle: $PenPresetsRowsTable.$converterhighlighterStyle.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}highlighter_style'],
        )!,
      ),
      highlighterHeight: $PenPresetsRowsTable.$converterhighlighterHeight
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}highlighter_height'],
            )!,
          ),
      highlighterColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}highlighter_color'],
      )!,
    );
  }

  @override
  $PenPresetsRowsTable createAlias(String alias) {
    return $PenPresetsRowsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const InstantConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<Hlc, String> $converterversionHlc = const HlcConverter();
  static TypeConverter<PenTip, String> $converterpenTip = const CodeConverter(
    PenTip.fromCode,
  );
  static TypeConverter<double, String> $converterpenWidthMm =
      const DecimalTextConverter(1);
  static TypeConverter<List<String>, String> $converterfavoriteColors =
      const StringListConverter();
  static TypeConverter<StrokeSize, String> $converterstrokeSize =
      const CodeConverter(StrokeSize.fromCode);
  static TypeConverter<HighlightStyle, String> $converterhighlighterStyle =
      const CodeConverter(HighlightStyle.fromCode);
  static TypeConverter<FillHeight, String> $converterhighlighterHeight =
      const CodeConverter(FillHeight.fromCode);
  @override
  bool get isStrict => true;
}

class PenPresetsRow extends DataClass implements Insertable<PenPresetsRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Hlc versionHlc;

  /// Colunas do servidor ainda desconhecidas por esta versão (parâmetro "Rest" do `put`).
  final String? extras;
  final String id;
  final String userId;
  final PenTip penTip;
  final double penWidthMm;
  final String penColor;
  final List<String> favoriteColors;
  final StrokeSize strokeSize;
  final HighlightStyle highlighterStyle;
  final FillHeight highlighterHeight;
  final String highlighterColor;
  const PenPresetsRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.versionHlc,
    this.extras,
    required this.id,
    required this.userId,
    required this.penTip,
    required this.penWidthMm,
    required this.penColor,
    required this.favoriteColors,
    required this.strokeSize,
    required this.highlighterStyle,
    required this.highlighterHeight,
    required this.highlighterColor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['created_at'] = Variable<String>(
        $PenPresetsRowsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $PenPresetsRowsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $PenPresetsRowsTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    {
      map['version_hlc'] = Variable<String>(
        $PenPresetsRowsTable.$converterversionHlc.toSql(versionHlc),
      );
    }
    if (!nullToAbsent || extras != null) {
      map['_extras'] = Variable<String>(extras);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    {
      map['pen_tip'] = Variable<String>(
        $PenPresetsRowsTable.$converterpenTip.toSql(penTip),
      );
    }
    {
      map['pen_width_mm'] = Variable<String>(
        $PenPresetsRowsTable.$converterpenWidthMm.toSql(penWidthMm),
      );
    }
    map['pen_color'] = Variable<String>(penColor);
    {
      map['favorite_colors'] = Variable<String>(
        $PenPresetsRowsTable.$converterfavoriteColors.toSql(favoriteColors),
      );
    }
    {
      map['stroke_size'] = Variable<String>(
        $PenPresetsRowsTable.$converterstrokeSize.toSql(strokeSize),
      );
    }
    {
      map['highlighter_style'] = Variable<String>(
        $PenPresetsRowsTable.$converterhighlighterStyle.toSql(highlighterStyle),
      );
    }
    {
      map['highlighter_height'] = Variable<String>(
        $PenPresetsRowsTable.$converterhighlighterHeight.toSql(
          highlighterHeight,
        ),
      );
    }
    map['highlighter_color'] = Variable<String>(highlighterColor);
    return map;
  }

  PenPresetsRowsCompanion toCompanion(bool nullToAbsent) {
    return PenPresetsRowsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      versionHlc: Value(versionHlc),
      extras: extras == null && nullToAbsent
          ? const Value.absent()
          : Value(extras),
      id: Value(id),
      userId: Value(userId),
      penTip: Value(penTip),
      penWidthMm: Value(penWidthMm),
      penColor: Value(penColor),
      favoriteColors: Value(favoriteColors),
      strokeSize: Value(strokeSize),
      highlighterStyle: Value(highlighterStyle),
      highlighterHeight: Value(highlighterHeight),
      highlighterColor: Value(highlighterColor),
    );
  }

  factory PenPresetsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PenPresetsRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      versionHlc: serializer.fromJson<Hlc>(json['versionHlc']),
      extras: serializer.fromJson<String?>(json['extras']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      penTip: serializer.fromJson<PenTip>(json['penTip']),
      penWidthMm: serializer.fromJson<double>(json['penWidthMm']),
      penColor: serializer.fromJson<String>(json['penColor']),
      favoriteColors: serializer.fromJson<List<String>>(json['favoriteColors']),
      strokeSize: serializer.fromJson<StrokeSize>(json['strokeSize']),
      highlighterStyle: serializer.fromJson<HighlightStyle>(
        json['highlighterStyle'],
      ),
      highlighterHeight: serializer.fromJson<FillHeight>(
        json['highlighterHeight'],
      ),
      highlighterColor: serializer.fromJson<String>(json['highlighterColor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'versionHlc': serializer.toJson<Hlc>(versionHlc),
      'extras': serializer.toJson<String?>(extras),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'penTip': serializer.toJson<PenTip>(penTip),
      'penWidthMm': serializer.toJson<double>(penWidthMm),
      'penColor': serializer.toJson<String>(penColor),
      'favoriteColors': serializer.toJson<List<String>>(favoriteColors),
      'strokeSize': serializer.toJson<StrokeSize>(strokeSize),
      'highlighterStyle': serializer.toJson<HighlightStyle>(highlighterStyle),
      'highlighterHeight': serializer.toJson<FillHeight>(highlighterHeight),
      'highlighterColor': serializer.toJson<String>(highlighterColor),
    };
  }

  PenPresetsRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Hlc? versionHlc,
    Value<String?> extras = const Value.absent(),
    String? id,
    String? userId,
    PenTip? penTip,
    double? penWidthMm,
    String? penColor,
    List<String>? favoriteColors,
    StrokeSize? strokeSize,
    HighlightStyle? highlighterStyle,
    FillHeight? highlighterHeight,
    String? highlighterColor,
  }) => PenPresetsRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    versionHlc: versionHlc ?? this.versionHlc,
    extras: extras.present ? extras.value : this.extras,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    penTip: penTip ?? this.penTip,
    penWidthMm: penWidthMm ?? this.penWidthMm,
    penColor: penColor ?? this.penColor,
    favoriteColors: favoriteColors ?? this.favoriteColors,
    strokeSize: strokeSize ?? this.strokeSize,
    highlighterStyle: highlighterStyle ?? this.highlighterStyle,
    highlighterHeight: highlighterHeight ?? this.highlighterHeight,
    highlighterColor: highlighterColor ?? this.highlighterColor,
  );
  PenPresetsRow copyWithCompanion(PenPresetsRowsCompanion data) {
    return PenPresetsRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      versionHlc: data.versionHlc.present
          ? data.versionHlc.value
          : this.versionHlc,
      extras: data.extras.present ? data.extras.value : this.extras,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      penTip: data.penTip.present ? data.penTip.value : this.penTip,
      penWidthMm: data.penWidthMm.present
          ? data.penWidthMm.value
          : this.penWidthMm,
      penColor: data.penColor.present ? data.penColor.value : this.penColor,
      favoriteColors: data.favoriteColors.present
          ? data.favoriteColors.value
          : this.favoriteColors,
      strokeSize: data.strokeSize.present
          ? data.strokeSize.value
          : this.strokeSize,
      highlighterStyle: data.highlighterStyle.present
          ? data.highlighterStyle.value
          : this.highlighterStyle,
      highlighterHeight: data.highlighterHeight.present
          ? data.highlighterHeight.value
          : this.highlighterHeight,
      highlighterColor: data.highlighterColor.present
          ? data.highlighterColor.value
          : this.highlighterColor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PenPresetsRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('penTip: $penTip, ')
          ..write('penWidthMm: $penWidthMm, ')
          ..write('penColor: $penColor, ')
          ..write('favoriteColors: $favoriteColors, ')
          ..write('strokeSize: $strokeSize, ')
          ..write('highlighterStyle: $highlighterStyle, ')
          ..write('highlighterHeight: $highlighterHeight, ')
          ..write('highlighterColor: $highlighterColor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    penTip,
    penWidthMm,
    penColor,
    favoriteColors,
    strokeSize,
    highlighterStyle,
    highlighterHeight,
    highlighterColor,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PenPresetsRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.versionHlc == this.versionHlc &&
          other.extras == this.extras &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.penTip == this.penTip &&
          other.penWidthMm == this.penWidthMm &&
          other.penColor == this.penColor &&
          other.favoriteColors == this.favoriteColors &&
          other.strokeSize == this.strokeSize &&
          other.highlighterStyle == this.highlighterStyle &&
          other.highlighterHeight == this.highlighterHeight &&
          other.highlighterColor == this.highlighterColor);
}

class PenPresetsRowsCompanion extends UpdateCompanion<PenPresetsRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<Hlc> versionHlc;
  final Value<String?> extras;
  final Value<String> id;
  final Value<String> userId;
  final Value<PenTip> penTip;
  final Value<double> penWidthMm;
  final Value<String> penColor;
  final Value<List<String>> favoriteColors;
  final Value<StrokeSize> strokeSize;
  final Value<HighlightStyle> highlighterStyle;
  final Value<FillHeight> highlighterHeight;
  final Value<String> highlighterColor;
  final Value<int> rowid;
  const PenPresetsRowsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.versionHlc = const Value.absent(),
    this.extras = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.penTip = const Value.absent(),
    this.penWidthMm = const Value.absent(),
    this.penColor = const Value.absent(),
    this.favoriteColors = const Value.absent(),
    this.strokeSize = const Value.absent(),
    this.highlighterStyle = const Value.absent(),
    this.highlighterHeight = const Value.absent(),
    this.highlighterColor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PenPresetsRowsCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required Hlc versionHlc,
    this.extras = const Value.absent(),
    required String id,
    required String userId,
    this.penTip = const Value.absent(),
    this.penWidthMm = const Value.absent(),
    this.penColor = const Value.absent(),
    this.favoriteColors = const Value.absent(),
    this.strokeSize = const Value.absent(),
    this.highlighterStyle = const Value.absent(),
    this.highlighterHeight = const Value.absent(),
    this.highlighterColor = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       versionHlc = Value(versionHlc),
       id = Value(id),
       userId = Value(userId);
  static Insertable<PenPresetsRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? versionHlc,
    Expression<String>? extras,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? penTip,
    Expression<String>? penWidthMm,
    Expression<String>? penColor,
    Expression<String>? favoriteColors,
    Expression<String>? strokeSize,
    Expression<String>? highlighterStyle,
    Expression<String>? highlighterHeight,
    Expression<String>? highlighterColor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (versionHlc != null) 'version_hlc': versionHlc,
      if (extras != null) '_extras': extras,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (penTip != null) 'pen_tip': penTip,
      if (penWidthMm != null) 'pen_width_mm': penWidthMm,
      if (penColor != null) 'pen_color': penColor,
      if (favoriteColors != null) 'favorite_colors': favoriteColors,
      if (strokeSize != null) 'stroke_size': strokeSize,
      if (highlighterStyle != null) 'highlighter_style': highlighterStyle,
      if (highlighterHeight != null) 'highlighter_height': highlighterHeight,
      if (highlighterColor != null) 'highlighter_color': highlighterColor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PenPresetsRowsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<Hlc>? versionHlc,
    Value<String?>? extras,
    Value<String>? id,
    Value<String>? userId,
    Value<PenTip>? penTip,
    Value<double>? penWidthMm,
    Value<String>? penColor,
    Value<List<String>>? favoriteColors,
    Value<StrokeSize>? strokeSize,
    Value<HighlightStyle>? highlighterStyle,
    Value<FillHeight>? highlighterHeight,
    Value<String>? highlighterColor,
    Value<int>? rowid,
  }) {
    return PenPresetsRowsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      versionHlc: versionHlc ?? this.versionHlc,
      extras: extras ?? this.extras,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      penTip: penTip ?? this.penTip,
      penWidthMm: penWidthMm ?? this.penWidthMm,
      penColor: penColor ?? this.penColor,
      favoriteColors: favoriteColors ?? this.favoriteColors,
      strokeSize: strokeSize ?? this.strokeSize,
      highlighterStyle: highlighterStyle ?? this.highlighterStyle,
      highlighterHeight: highlighterHeight ?? this.highlighterHeight,
      highlighterColor: highlighterColor ?? this.highlighterColor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $PenPresetsRowsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $PenPresetsRowsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $PenPresetsRowsTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (versionHlc.present) {
      map['version_hlc'] = Variable<String>(
        $PenPresetsRowsTable.$converterversionHlc.toSql(versionHlc.value),
      );
    }
    if (extras.present) {
      map['_extras'] = Variable<String>(extras.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (penTip.present) {
      map['pen_tip'] = Variable<String>(
        $PenPresetsRowsTable.$converterpenTip.toSql(penTip.value),
      );
    }
    if (penWidthMm.present) {
      map['pen_width_mm'] = Variable<String>(
        $PenPresetsRowsTable.$converterpenWidthMm.toSql(penWidthMm.value),
      );
    }
    if (penColor.present) {
      map['pen_color'] = Variable<String>(penColor.value);
    }
    if (favoriteColors.present) {
      map['favorite_colors'] = Variable<String>(
        $PenPresetsRowsTable.$converterfavoriteColors.toSql(
          favoriteColors.value,
        ),
      );
    }
    if (strokeSize.present) {
      map['stroke_size'] = Variable<String>(
        $PenPresetsRowsTable.$converterstrokeSize.toSql(strokeSize.value),
      );
    }
    if (highlighterStyle.present) {
      map['highlighter_style'] = Variable<String>(
        $PenPresetsRowsTable.$converterhighlighterStyle.toSql(
          highlighterStyle.value,
        ),
      );
    }
    if (highlighterHeight.present) {
      map['highlighter_height'] = Variable<String>(
        $PenPresetsRowsTable.$converterhighlighterHeight.toSql(
          highlighterHeight.value,
        ),
      );
    }
    if (highlighterColor.present) {
      map['highlighter_color'] = Variable<String>(highlighterColor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PenPresetsRowsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('penTip: $penTip, ')
          ..write('penWidthMm: $penWidthMm, ')
          ..write('penColor: $penColor, ')
          ..write('favoriteColors: $favoriteColors, ')
          ..write('strokeSize: $strokeSize, ')
          ..write('highlighterStyle: $highlighterStyle, ')
          ..write('highlighterHeight: $highlighterHeight, ')
          ..write('highlighterColor: $highlighterColor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingGoalsRowsTable extends ReadingGoalsRows
    with TableInfo<$ReadingGoalsRowsTable, ReadingGoalsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingGoalsRowsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReadingGoalsRowsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReadingGoalsRowsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ReadingGoalsRowsTable.$converterdeletedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> versionHlc =
      GeneratedColumn<String>(
        'version_hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($ReadingGoalsRowsTable.$converterversionHlc);
  static const VerificationMeta _extrasMeta = const VerificationMeta('extras');
  @override
  late final GeneratedColumn<String> extras = GeneratedColumn<String>(
    '_extras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  static const VerificationMeta _dailyMinutesMeta = const VerificationMeta(
    'dailyMinutes',
  );
  @override
  late final GeneratedColumn<int> dailyMinutes = GeneratedColumn<int>(
    'daily_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _badgeTargetDaysMeta = const VerificationMeta(
    'badgeTargetDays',
  );
  @override
  late final GeneratedColumn<int> badgeTargetDays = GeneratedColumn<int>(
    'badge_target_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    dailyMinutes,
    badgeTargetDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingGoalsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('_extras')) {
      context.handle(
        _extrasMeta,
        extras.isAcceptableOrUnknown(data['_extras']!, _extrasMeta),
      );
    }
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
    if (data.containsKey('daily_minutes')) {
      context.handle(
        _dailyMinutesMeta,
        dailyMinutes.isAcceptableOrUnknown(
          data['daily_minutes']!,
          _dailyMinutesMeta,
        ),
      );
    }
    if (data.containsKey('badge_target_days')) {
      context.handle(
        _badgeTargetDaysMeta,
        badgeTargetDays.isAcceptableOrUnknown(
          data['badge_target_days']!,
          _badgeTargetDaysMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingGoalsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingGoalsRow(
      createdAt: $ReadingGoalsRowsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $ReadingGoalsRowsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $ReadingGoalsRowsTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      versionHlc: $ReadingGoalsRowsTable.$converterversionHlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}version_hlc'],
        )!,
      ),
      extras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}_extras'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      dailyMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_minutes'],
      )!,
      badgeTargetDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}badge_target_days'],
      )!,
    );
  }

  @override
  $ReadingGoalsRowsTable createAlias(String alias) {
    return $ReadingGoalsRowsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const InstantConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const InstantConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<Hlc, String> $converterversionHlc = const HlcConverter();
  @override
  bool get isStrict => true;
}

class ReadingGoalsRow extends DataClass implements Insertable<ReadingGoalsRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Hlc versionHlc;

  /// Colunas do servidor ainda desconhecidas por esta versão (parâmetro "Rest" do `put`).
  final String? extras;
  final String id;
  final String userId;
  final int dailyMinutes;
  final int badgeTargetDays;
  const ReadingGoalsRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.versionHlc,
    this.extras,
    required this.id,
    required this.userId,
    required this.dailyMinutes,
    required this.badgeTargetDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['created_at'] = Variable<String>(
        $ReadingGoalsRowsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $ReadingGoalsRowsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $ReadingGoalsRowsTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    {
      map['version_hlc'] = Variable<String>(
        $ReadingGoalsRowsTable.$converterversionHlc.toSql(versionHlc),
      );
    }
    if (!nullToAbsent || extras != null) {
      map['_extras'] = Variable<String>(extras);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['daily_minutes'] = Variable<int>(dailyMinutes);
    map['badge_target_days'] = Variable<int>(badgeTargetDays);
    return map;
  }

  ReadingGoalsRowsCompanion toCompanion(bool nullToAbsent) {
    return ReadingGoalsRowsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      versionHlc: Value(versionHlc),
      extras: extras == null && nullToAbsent
          ? const Value.absent()
          : Value(extras),
      id: Value(id),
      userId: Value(userId),
      dailyMinutes: Value(dailyMinutes),
      badgeTargetDays: Value(badgeTargetDays),
    );
  }

  factory ReadingGoalsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingGoalsRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      versionHlc: serializer.fromJson<Hlc>(json['versionHlc']),
      extras: serializer.fromJson<String?>(json['extras']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      dailyMinutes: serializer.fromJson<int>(json['dailyMinutes']),
      badgeTargetDays: serializer.fromJson<int>(json['badgeTargetDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'versionHlc': serializer.toJson<Hlc>(versionHlc),
      'extras': serializer.toJson<String?>(extras),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'dailyMinutes': serializer.toJson<int>(dailyMinutes),
      'badgeTargetDays': serializer.toJson<int>(badgeTargetDays),
    };
  }

  ReadingGoalsRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Hlc? versionHlc,
    Value<String?> extras = const Value.absent(),
    String? id,
    String? userId,
    int? dailyMinutes,
    int? badgeTargetDays,
  }) => ReadingGoalsRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    versionHlc: versionHlc ?? this.versionHlc,
    extras: extras.present ? extras.value : this.extras,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    dailyMinutes: dailyMinutes ?? this.dailyMinutes,
    badgeTargetDays: badgeTargetDays ?? this.badgeTargetDays,
  );
  ReadingGoalsRow copyWithCompanion(ReadingGoalsRowsCompanion data) {
    return ReadingGoalsRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      versionHlc: data.versionHlc.present
          ? data.versionHlc.value
          : this.versionHlc,
      extras: data.extras.present ? data.extras.value : this.extras,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      dailyMinutes: data.dailyMinutes.present
          ? data.dailyMinutes.value
          : this.dailyMinutes,
      badgeTargetDays: data.badgeTargetDays.present
          ? data.badgeTargetDays.value
          : this.badgeTargetDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingGoalsRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dailyMinutes: $dailyMinutes, ')
          ..write('badgeTargetDays: $badgeTargetDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    versionHlc,
    extras,
    id,
    userId,
    dailyMinutes,
    badgeTargetDays,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingGoalsRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.versionHlc == this.versionHlc &&
          other.extras == this.extras &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.dailyMinutes == this.dailyMinutes &&
          other.badgeTargetDays == this.badgeTargetDays);
}

class ReadingGoalsRowsCompanion extends UpdateCompanion<ReadingGoalsRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<Hlc> versionHlc;
  final Value<String?> extras;
  final Value<String> id;
  final Value<String> userId;
  final Value<int> dailyMinutes;
  final Value<int> badgeTargetDays;
  final Value<int> rowid;
  const ReadingGoalsRowsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.versionHlc = const Value.absent(),
    this.extras = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.dailyMinutes = const Value.absent(),
    this.badgeTargetDays = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingGoalsRowsCompanion.insert({
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required Hlc versionHlc,
    this.extras = const Value.absent(),
    required String id,
    required String userId,
    this.dailyMinutes = const Value.absent(),
    this.badgeTargetDays = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       versionHlc = Value(versionHlc),
       id = Value(id),
       userId = Value(userId);
  static Insertable<ReadingGoalsRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? versionHlc,
    Expression<String>? extras,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? dailyMinutes,
    Expression<int>? badgeTargetDays,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (versionHlc != null) 'version_hlc': versionHlc,
      if (extras != null) '_extras': extras,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (dailyMinutes != null) 'daily_minutes': dailyMinutes,
      if (badgeTargetDays != null) 'badge_target_days': badgeTargetDays,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingGoalsRowsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<Hlc>? versionHlc,
    Value<String?>? extras,
    Value<String>? id,
    Value<String>? userId,
    Value<int>? dailyMinutes,
    Value<int>? badgeTargetDays,
    Value<int>? rowid,
  }) {
    return ReadingGoalsRowsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      versionHlc: versionHlc ?? this.versionHlc,
      extras: extras ?? this.extras,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      badgeTargetDays: badgeTargetDays ?? this.badgeTargetDays,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $ReadingGoalsRowsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $ReadingGoalsRowsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $ReadingGoalsRowsTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (versionHlc.present) {
      map['version_hlc'] = Variable<String>(
        $ReadingGoalsRowsTable.$converterversionHlc.toSql(versionHlc.value),
      );
    }
    if (extras.present) {
      map['_extras'] = Variable<String>(extras.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (dailyMinutes.present) {
      map['daily_minutes'] = Variable<int>(dailyMinutes.value);
    }
    if (badgeTargetDays.present) {
      map['badge_target_days'] = Variable<int>(badgeTargetDays.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingGoalsRowsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionHlc: $versionHlc, ')
          ..write('extras: $extras, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dailyMinutes: $dailyMinutes, ')
          ..write('badgeTargetDays: $badgeTargetDays, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KvTable extends Kv with TableInfo<$KvTable, KvRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KvTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kv';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $KvTable createAlias(String alias) {
    return $KvTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class KvRow extends DataClass implements Insertable<KvRow> {
  final String key;
  final String value;
  const KvRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KvCompanion toCompanion(bool nullToAbsent) {
    return KvCompanion(key: Value(key), value: Value(value));
  }

  factory KvRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KvRow copyWith({String? key, String? value}) =>
      KvRow(key: key ?? this.key, value: value ?? this.value);
  KvRow copyWithCompanion(KvCompanion data) {
    return KvRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvRow && other.key == this.key && other.value == this.value);
}

class KvCompanion extends UpdateCompanion<KvRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KvCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KvRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KvCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFilesTable extends LocalFiles
    with TableInfo<$LocalFilesTable, LocalFileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadStateMeta = const VerificationMeta(
    'uploadState',
  );
  @override
  late final GeneratedColumn<String> uploadState = GeneratedColumn<String>(
    'upload_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($LocalFilesTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    userBookId,
    path,
    bytes,
    sha256,
    uploadState,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalFileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('upload_state')) {
      context.handle(
        _uploadStateMeta,
        uploadState.isAcceptableOrUnknown(
          data['upload_state']!,
          _uploadStateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userBookId};
  @override
  LocalFileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFileRow(
      userBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_book_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      uploadState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upload_state'],
      )!,
      updatedAt: $LocalFilesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $LocalFilesTable createAlias(String alias) {
    return $LocalFilesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterupdatedAt =
      const InstantConverter();
  @override
  bool get isStrict => true;
}

class LocalFileRow extends DataClass implements Insertable<LocalFileRow> {
  final String userBookId;
  final String path;
  final int bytes;
  final String sha256;
  final String uploadState;
  final DateTime updatedAt;
  const LocalFileRow({
    required this.userBookId,
    required this.path,
    required this.bytes,
    required this.sha256,
    required this.uploadState,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_book_id'] = Variable<String>(userBookId);
    map['path'] = Variable<String>(path);
    map['bytes'] = Variable<int>(bytes);
    map['sha256'] = Variable<String>(sha256);
    map['upload_state'] = Variable<String>(uploadState);
    {
      map['updated_at'] = Variable<String>(
        $LocalFilesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  LocalFilesCompanion toCompanion(bool nullToAbsent) {
    return LocalFilesCompanion(
      userBookId: Value(userBookId),
      path: Value(path),
      bytes: Value(bytes),
      sha256: Value(sha256),
      uploadState: Value(uploadState),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalFileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFileRow(
      userBookId: serializer.fromJson<String>(json['userBookId']),
      path: serializer.fromJson<String>(json['path']),
      bytes: serializer.fromJson<int>(json['bytes']),
      sha256: serializer.fromJson<String>(json['sha256']),
      uploadState: serializer.fromJson<String>(json['uploadState']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userBookId': serializer.toJson<String>(userBookId),
      'path': serializer.toJson<String>(path),
      'bytes': serializer.toJson<int>(bytes),
      'sha256': serializer.toJson<String>(sha256),
      'uploadState': serializer.toJson<String>(uploadState),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalFileRow copyWith({
    String? userBookId,
    String? path,
    int? bytes,
    String? sha256,
    String? uploadState,
    DateTime? updatedAt,
  }) => LocalFileRow(
    userBookId: userBookId ?? this.userBookId,
    path: path ?? this.path,
    bytes: bytes ?? this.bytes,
    sha256: sha256 ?? this.sha256,
    uploadState: uploadState ?? this.uploadState,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalFileRow copyWithCompanion(LocalFilesCompanion data) {
    return LocalFileRow(
      userBookId: data.userBookId.present
          ? data.userBookId.value
          : this.userBookId,
      path: data.path.present ? data.path.value : this.path,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      uploadState: data.uploadState.present
          ? data.uploadState.value
          : this.uploadState,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFileRow(')
          ..write('userBookId: $userBookId, ')
          ..write('path: $path, ')
          ..write('bytes: $bytes, ')
          ..write('sha256: $sha256, ')
          ..write('uploadState: $uploadState, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userBookId, path, bytes, sha256, uploadState, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFileRow &&
          other.userBookId == this.userBookId &&
          other.path == this.path &&
          other.bytes == this.bytes &&
          other.sha256 == this.sha256 &&
          other.uploadState == this.uploadState &&
          other.updatedAt == this.updatedAt);
}

class LocalFilesCompanion extends UpdateCompanion<LocalFileRow> {
  final Value<String> userBookId;
  final Value<String> path;
  final Value<int> bytes;
  final Value<String> sha256;
  final Value<String> uploadState;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalFilesCompanion({
    this.userBookId = const Value.absent(),
    this.path = const Value.absent(),
    this.bytes = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.uploadState = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFilesCompanion.insert({
    required String userBookId,
    required String path,
    required int bytes,
    required String sha256,
    this.uploadState = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : userBookId = Value(userBookId),
       path = Value(path),
       bytes = Value(bytes),
       sha256 = Value(sha256),
       updatedAt = Value(updatedAt);
  static Insertable<LocalFileRow> custom({
    Expression<String>? userBookId,
    Expression<String>? path,
    Expression<int>? bytes,
    Expression<String>? sha256,
    Expression<String>? uploadState,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userBookId != null) 'user_book_id': userBookId,
      if (path != null) 'path': path,
      if (bytes != null) 'bytes': bytes,
      if (sha256 != null) 'sha256': sha256,
      if (uploadState != null) 'upload_state': uploadState,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFilesCompanion copyWith({
    Value<String>? userBookId,
    Value<String>? path,
    Value<int>? bytes,
    Value<String>? sha256,
    Value<String>? uploadState,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalFilesCompanion(
      userBookId: userBookId ?? this.userBookId,
      path: path ?? this.path,
      bytes: bytes ?? this.bytes,
      sha256: sha256 ?? this.sha256,
      uploadState: uploadState ?? this.uploadState,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userBookId.present) {
      map['user_book_id'] = Variable<String>(userBookId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (uploadState.present) {
      map['upload_state'] = Variable<String>(uploadState.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $LocalFilesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFilesCompanion(')
          ..write('userBookId: $userBookId, ')
          ..write('path: $path, ')
          ..write('bytes: $bytes, ')
          ..write('sha256: $sha256, ')
          ..write('uploadState: $uploadState, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookContentIndexTable extends BookContentIndex
    with TableInfo<$BookContentIndexTable, BookContentIndexRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookContentIndexTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _contentSha256Meta = const VerificationMeta(
    'contentSha256',
  );
  @override
  late final GeneratedColumn<String> contentSha256 = GeneratedColumn<String>(
    'content_sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refPageVersionMeta = const VerificationMeta(
    'refPageVersion',
  );
  @override
  late final GeneratedColumn<int> refPageVersion = GeneratedColumn<int>(
    'ref_page_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spineJsonMeta = const VerificationMeta(
    'spineJson',
  );
  @override
  late final GeneratedColumn<String> spineJson = GeneratedColumn<String>(
    'spine_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _charCountsJsonMeta = const VerificationMeta(
    'charCountsJson',
  );
  @override
  late final GeneratedColumn<String> charCountsJson = GeneratedColumn<String>(
    'char_counts_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tocJsonMeta = const VerificationMeta(
    'tocJson',
  );
  @override
  late final GeneratedColumn<String> tocJson = GeneratedColumn<String>(
    'toc_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refPagesJsonMeta = const VerificationMeta(
    'refPagesJson',
  );
  @override
  late final GeneratedColumn<String> refPagesJson = GeneratedColumn<String>(
    'ref_pages_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> builtAt =
      GeneratedColumn<String>(
        'built_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($BookContentIndexTable.$converterbuiltAt);
  @override
  List<GeneratedColumn> get $columns => [
    userBookId,
    contentSha256,
    refPageVersion,
    spineJson,
    charCountsJson,
    tocJson,
    refPagesJson,
    builtAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_content_index';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookContentIndexRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('content_sha256')) {
      context.handle(
        _contentSha256Meta,
        contentSha256.isAcceptableOrUnknown(
          data['content_sha256']!,
          _contentSha256Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentSha256Meta);
    }
    if (data.containsKey('ref_page_version')) {
      context.handle(
        _refPageVersionMeta,
        refPageVersion.isAcceptableOrUnknown(
          data['ref_page_version']!,
          _refPageVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refPageVersionMeta);
    }
    if (data.containsKey('spine_json')) {
      context.handle(
        _spineJsonMeta,
        spineJson.isAcceptableOrUnknown(data['spine_json']!, _spineJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_spineJsonMeta);
    }
    if (data.containsKey('char_counts_json')) {
      context.handle(
        _charCountsJsonMeta,
        charCountsJson.isAcceptableOrUnknown(
          data['char_counts_json']!,
          _charCountsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_charCountsJsonMeta);
    }
    if (data.containsKey('toc_json')) {
      context.handle(
        _tocJsonMeta,
        tocJson.isAcceptableOrUnknown(data['toc_json']!, _tocJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_tocJsonMeta);
    }
    if (data.containsKey('ref_pages_json')) {
      context.handle(
        _refPagesJsonMeta,
        refPagesJson.isAcceptableOrUnknown(
          data['ref_pages_json']!,
          _refPagesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refPagesJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userBookId};
  @override
  BookContentIndexRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookContentIndexRow(
      userBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_book_id'],
      )!,
      contentSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_sha256'],
      )!,
      refPageVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ref_page_version'],
      )!,
      spineJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spine_json'],
      )!,
      charCountsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}char_counts_json'],
      )!,
      tocJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}toc_json'],
      )!,
      refPagesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_pages_json'],
      )!,
      builtAt: $BookContentIndexTable.$converterbuiltAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}built_at'],
        )!,
      ),
    );
  }

  @override
  $BookContentIndexTable createAlias(String alias) {
    return $BookContentIndexTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterbuiltAt =
      const InstantConverter();
  @override
  bool get isStrict => true;
}

class BookContentIndexRow extends DataClass
    implements Insertable<BookContentIndexRow> {
  final String userBookId;
  final String contentSha256;
  final int refPageVersion;
  final String spineJson;
  final String charCountsJson;
  final String tocJson;
  final String refPagesJson;
  final DateTime builtAt;
  const BookContentIndexRow({
    required this.userBookId,
    required this.contentSha256,
    required this.refPageVersion,
    required this.spineJson,
    required this.charCountsJson,
    required this.tocJson,
    required this.refPagesJson,
    required this.builtAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_book_id'] = Variable<String>(userBookId);
    map['content_sha256'] = Variable<String>(contentSha256);
    map['ref_page_version'] = Variable<int>(refPageVersion);
    map['spine_json'] = Variable<String>(spineJson);
    map['char_counts_json'] = Variable<String>(charCountsJson);
    map['toc_json'] = Variable<String>(tocJson);
    map['ref_pages_json'] = Variable<String>(refPagesJson);
    {
      map['built_at'] = Variable<String>(
        $BookContentIndexTable.$converterbuiltAt.toSql(builtAt),
      );
    }
    return map;
  }

  BookContentIndexCompanion toCompanion(bool nullToAbsent) {
    return BookContentIndexCompanion(
      userBookId: Value(userBookId),
      contentSha256: Value(contentSha256),
      refPageVersion: Value(refPageVersion),
      spineJson: Value(spineJson),
      charCountsJson: Value(charCountsJson),
      tocJson: Value(tocJson),
      refPagesJson: Value(refPagesJson),
      builtAt: Value(builtAt),
    );
  }

  factory BookContentIndexRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookContentIndexRow(
      userBookId: serializer.fromJson<String>(json['userBookId']),
      contentSha256: serializer.fromJson<String>(json['contentSha256']),
      refPageVersion: serializer.fromJson<int>(json['refPageVersion']),
      spineJson: serializer.fromJson<String>(json['spineJson']),
      charCountsJson: serializer.fromJson<String>(json['charCountsJson']),
      tocJson: serializer.fromJson<String>(json['tocJson']),
      refPagesJson: serializer.fromJson<String>(json['refPagesJson']),
      builtAt: serializer.fromJson<DateTime>(json['builtAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userBookId': serializer.toJson<String>(userBookId),
      'contentSha256': serializer.toJson<String>(contentSha256),
      'refPageVersion': serializer.toJson<int>(refPageVersion),
      'spineJson': serializer.toJson<String>(spineJson),
      'charCountsJson': serializer.toJson<String>(charCountsJson),
      'tocJson': serializer.toJson<String>(tocJson),
      'refPagesJson': serializer.toJson<String>(refPagesJson),
      'builtAt': serializer.toJson<DateTime>(builtAt),
    };
  }

  BookContentIndexRow copyWith({
    String? userBookId,
    String? contentSha256,
    int? refPageVersion,
    String? spineJson,
    String? charCountsJson,
    String? tocJson,
    String? refPagesJson,
    DateTime? builtAt,
  }) => BookContentIndexRow(
    userBookId: userBookId ?? this.userBookId,
    contentSha256: contentSha256 ?? this.contentSha256,
    refPageVersion: refPageVersion ?? this.refPageVersion,
    spineJson: spineJson ?? this.spineJson,
    charCountsJson: charCountsJson ?? this.charCountsJson,
    tocJson: tocJson ?? this.tocJson,
    refPagesJson: refPagesJson ?? this.refPagesJson,
    builtAt: builtAt ?? this.builtAt,
  );
  BookContentIndexRow copyWithCompanion(BookContentIndexCompanion data) {
    return BookContentIndexRow(
      userBookId: data.userBookId.present
          ? data.userBookId.value
          : this.userBookId,
      contentSha256: data.contentSha256.present
          ? data.contentSha256.value
          : this.contentSha256,
      refPageVersion: data.refPageVersion.present
          ? data.refPageVersion.value
          : this.refPageVersion,
      spineJson: data.spineJson.present ? data.spineJson.value : this.spineJson,
      charCountsJson: data.charCountsJson.present
          ? data.charCountsJson.value
          : this.charCountsJson,
      tocJson: data.tocJson.present ? data.tocJson.value : this.tocJson,
      refPagesJson: data.refPagesJson.present
          ? data.refPagesJson.value
          : this.refPagesJson,
      builtAt: data.builtAt.present ? data.builtAt.value : this.builtAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookContentIndexRow(')
          ..write('userBookId: $userBookId, ')
          ..write('contentSha256: $contentSha256, ')
          ..write('refPageVersion: $refPageVersion, ')
          ..write('spineJson: $spineJson, ')
          ..write('charCountsJson: $charCountsJson, ')
          ..write('tocJson: $tocJson, ')
          ..write('refPagesJson: $refPagesJson, ')
          ..write('builtAt: $builtAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userBookId,
    contentSha256,
    refPageVersion,
    spineJson,
    charCountsJson,
    tocJson,
    refPagesJson,
    builtAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookContentIndexRow &&
          other.userBookId == this.userBookId &&
          other.contentSha256 == this.contentSha256 &&
          other.refPageVersion == this.refPageVersion &&
          other.spineJson == this.spineJson &&
          other.charCountsJson == this.charCountsJson &&
          other.tocJson == this.tocJson &&
          other.refPagesJson == this.refPagesJson &&
          other.builtAt == this.builtAt);
}

class BookContentIndexCompanion extends UpdateCompanion<BookContentIndexRow> {
  final Value<String> userBookId;
  final Value<String> contentSha256;
  final Value<int> refPageVersion;
  final Value<String> spineJson;
  final Value<String> charCountsJson;
  final Value<String> tocJson;
  final Value<String> refPagesJson;
  final Value<DateTime> builtAt;
  final Value<int> rowid;
  const BookContentIndexCompanion({
    this.userBookId = const Value.absent(),
    this.contentSha256 = const Value.absent(),
    this.refPageVersion = const Value.absent(),
    this.spineJson = const Value.absent(),
    this.charCountsJson = const Value.absent(),
    this.tocJson = const Value.absent(),
    this.refPagesJson = const Value.absent(),
    this.builtAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookContentIndexCompanion.insert({
    required String userBookId,
    required String contentSha256,
    required int refPageVersion,
    required String spineJson,
    required String charCountsJson,
    required String tocJson,
    required String refPagesJson,
    required DateTime builtAt,
    this.rowid = const Value.absent(),
  }) : userBookId = Value(userBookId),
       contentSha256 = Value(contentSha256),
       refPageVersion = Value(refPageVersion),
       spineJson = Value(spineJson),
       charCountsJson = Value(charCountsJson),
       tocJson = Value(tocJson),
       refPagesJson = Value(refPagesJson),
       builtAt = Value(builtAt);
  static Insertable<BookContentIndexRow> custom({
    Expression<String>? userBookId,
    Expression<String>? contentSha256,
    Expression<int>? refPageVersion,
    Expression<String>? spineJson,
    Expression<String>? charCountsJson,
    Expression<String>? tocJson,
    Expression<String>? refPagesJson,
    Expression<String>? builtAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userBookId != null) 'user_book_id': userBookId,
      if (contentSha256 != null) 'content_sha256': contentSha256,
      if (refPageVersion != null) 'ref_page_version': refPageVersion,
      if (spineJson != null) 'spine_json': spineJson,
      if (charCountsJson != null) 'char_counts_json': charCountsJson,
      if (tocJson != null) 'toc_json': tocJson,
      if (refPagesJson != null) 'ref_pages_json': refPagesJson,
      if (builtAt != null) 'built_at': builtAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookContentIndexCompanion copyWith({
    Value<String>? userBookId,
    Value<String>? contentSha256,
    Value<int>? refPageVersion,
    Value<String>? spineJson,
    Value<String>? charCountsJson,
    Value<String>? tocJson,
    Value<String>? refPagesJson,
    Value<DateTime>? builtAt,
    Value<int>? rowid,
  }) {
    return BookContentIndexCompanion(
      userBookId: userBookId ?? this.userBookId,
      contentSha256: contentSha256 ?? this.contentSha256,
      refPageVersion: refPageVersion ?? this.refPageVersion,
      spineJson: spineJson ?? this.spineJson,
      charCountsJson: charCountsJson ?? this.charCountsJson,
      tocJson: tocJson ?? this.tocJson,
      refPagesJson: refPagesJson ?? this.refPagesJson,
      builtAt: builtAt ?? this.builtAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userBookId.present) {
      map['user_book_id'] = Variable<String>(userBookId.value);
    }
    if (contentSha256.present) {
      map['content_sha256'] = Variable<String>(contentSha256.value);
    }
    if (refPageVersion.present) {
      map['ref_page_version'] = Variable<int>(refPageVersion.value);
    }
    if (spineJson.present) {
      map['spine_json'] = Variable<String>(spineJson.value);
    }
    if (charCountsJson.present) {
      map['char_counts_json'] = Variable<String>(charCountsJson.value);
    }
    if (tocJson.present) {
      map['toc_json'] = Variable<String>(tocJson.value);
    }
    if (refPagesJson.present) {
      map['ref_pages_json'] = Variable<String>(refPagesJson.value);
    }
    if (builtAt.present) {
      map['built_at'] = Variable<String>(
        $BookContentIndexTable.$converterbuiltAt.toSql(builtAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookContentIndexCompanion(')
          ..write('userBookId: $userBookId, ')
          ..write('contentSha256: $contentSha256, ')
          ..write('refPageVersion: $refPageVersion, ')
          ..write('spineJson: $spineJson, ')
          ..write('charCountsJson: $charCountsJson, ')
          ..write('tocJson: $tocJson, ')
          ..write('refPagesJson: $refPagesJson, ')
          ..write('builtAt: $builtAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PageLayoutCacheTable extends PageLayoutCache
    with TableInfo<$PageLayoutCacheTable, PageLayoutCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PageLayoutCacheTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _settingsHashMeta = const VerificationMeta(
    'settingsHash',
  );
  @override
  late final GeneratedColumn<String> settingsHash = GeneratedColumn<String>(
    'settings_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _viewportMeta = const VerificationMeta(
    'viewport',
  );
  @override
  late final GeneratedColumn<String> viewport = GeneratedColumn<String>(
    'viewport',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fontsVersionMeta = const VerificationMeta(
    'fontsVersion',
  );
  @override
  late final GeneratedColumn<int> fontsVersion = GeneratedColumn<int>(
    'fonts_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breaksMeta = const VerificationMeta('breaks');
  @override
  late final GeneratedColumn<Uint8List> breaks = GeneratedColumn<Uint8List>(
    'breaks',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PageLayoutCacheTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    userBookId,
    settingsHash,
    viewport,
    fontsVersion,
    breaks,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'page_layout_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<PageLayoutCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('settings_hash')) {
      context.handle(
        _settingsHashMeta,
        settingsHash.isAcceptableOrUnknown(
          data['settings_hash']!,
          _settingsHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settingsHashMeta);
    }
    if (data.containsKey('viewport')) {
      context.handle(
        _viewportMeta,
        viewport.isAcceptableOrUnknown(data['viewport']!, _viewportMeta),
      );
    } else if (isInserting) {
      context.missing(_viewportMeta);
    }
    if (data.containsKey('fonts_version')) {
      context.handle(
        _fontsVersionMeta,
        fontsVersion.isAcceptableOrUnknown(
          data['fonts_version']!,
          _fontsVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fontsVersionMeta);
    }
    if (data.containsKey('breaks')) {
      context.handle(
        _breaksMeta,
        breaks.isAcceptableOrUnknown(data['breaks']!, _breaksMeta),
      );
    } else if (isInserting) {
      context.missing(_breaksMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    userBookId,
    settingsHash,
    viewport,
    fontsVersion,
  };
  @override
  PageLayoutCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PageLayoutCacheRow(
      userBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_book_id'],
      )!,
      settingsHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_hash'],
      )!,
      viewport: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}viewport'],
      )!,
      fontsVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fonts_version'],
      )!,
      breaks: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}breaks'],
      )!,
      createdAt: $PageLayoutCacheTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $PageLayoutCacheTable createAlias(String alias) {
    return $PageLayoutCacheTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const InstantConverter();
  @override
  bool get isStrict => true;
}

class PageLayoutCacheRow extends DataClass
    implements Insertable<PageLayoutCacheRow> {
  final String userBookId;
  final String settingsHash;

  /// `<largura>x<altura>@<dpr>` em px lógicos.
  final String viewport;
  final int fontsVersion;
  final Uint8List breaks;
  final DateTime createdAt;
  const PageLayoutCacheRow({
    required this.userBookId,
    required this.settingsHash,
    required this.viewport,
    required this.fontsVersion,
    required this.breaks,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_book_id'] = Variable<String>(userBookId);
    map['settings_hash'] = Variable<String>(settingsHash);
    map['viewport'] = Variable<String>(viewport);
    map['fonts_version'] = Variable<int>(fontsVersion);
    map['breaks'] = Variable<Uint8List>(breaks);
    {
      map['created_at'] = Variable<String>(
        $PageLayoutCacheTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  PageLayoutCacheCompanion toCompanion(bool nullToAbsent) {
    return PageLayoutCacheCompanion(
      userBookId: Value(userBookId),
      settingsHash: Value(settingsHash),
      viewport: Value(viewport),
      fontsVersion: Value(fontsVersion),
      breaks: Value(breaks),
      createdAt: Value(createdAt),
    );
  }

  factory PageLayoutCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PageLayoutCacheRow(
      userBookId: serializer.fromJson<String>(json['userBookId']),
      settingsHash: serializer.fromJson<String>(json['settingsHash']),
      viewport: serializer.fromJson<String>(json['viewport']),
      fontsVersion: serializer.fromJson<int>(json['fontsVersion']),
      breaks: serializer.fromJson<Uint8List>(json['breaks']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userBookId': serializer.toJson<String>(userBookId),
      'settingsHash': serializer.toJson<String>(settingsHash),
      'viewport': serializer.toJson<String>(viewport),
      'fontsVersion': serializer.toJson<int>(fontsVersion),
      'breaks': serializer.toJson<Uint8List>(breaks),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PageLayoutCacheRow copyWith({
    String? userBookId,
    String? settingsHash,
    String? viewport,
    int? fontsVersion,
    Uint8List? breaks,
    DateTime? createdAt,
  }) => PageLayoutCacheRow(
    userBookId: userBookId ?? this.userBookId,
    settingsHash: settingsHash ?? this.settingsHash,
    viewport: viewport ?? this.viewport,
    fontsVersion: fontsVersion ?? this.fontsVersion,
    breaks: breaks ?? this.breaks,
    createdAt: createdAt ?? this.createdAt,
  );
  PageLayoutCacheRow copyWithCompanion(PageLayoutCacheCompanion data) {
    return PageLayoutCacheRow(
      userBookId: data.userBookId.present
          ? data.userBookId.value
          : this.userBookId,
      settingsHash: data.settingsHash.present
          ? data.settingsHash.value
          : this.settingsHash,
      viewport: data.viewport.present ? data.viewport.value : this.viewport,
      fontsVersion: data.fontsVersion.present
          ? data.fontsVersion.value
          : this.fontsVersion,
      breaks: data.breaks.present ? data.breaks.value : this.breaks,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PageLayoutCacheRow(')
          ..write('userBookId: $userBookId, ')
          ..write('settingsHash: $settingsHash, ')
          ..write('viewport: $viewport, ')
          ..write('fontsVersion: $fontsVersion, ')
          ..write('breaks: $breaks, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userBookId,
    settingsHash,
    viewport,
    fontsVersion,
    $driftBlobEquality.hash(breaks),
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PageLayoutCacheRow &&
          other.userBookId == this.userBookId &&
          other.settingsHash == this.settingsHash &&
          other.viewport == this.viewport &&
          other.fontsVersion == this.fontsVersion &&
          $driftBlobEquality.equals(other.breaks, this.breaks) &&
          other.createdAt == this.createdAt);
}

class PageLayoutCacheCompanion extends UpdateCompanion<PageLayoutCacheRow> {
  final Value<String> userBookId;
  final Value<String> settingsHash;
  final Value<String> viewport;
  final Value<int> fontsVersion;
  final Value<Uint8List> breaks;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PageLayoutCacheCompanion({
    this.userBookId = const Value.absent(),
    this.settingsHash = const Value.absent(),
    this.viewport = const Value.absent(),
    this.fontsVersion = const Value.absent(),
    this.breaks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PageLayoutCacheCompanion.insert({
    required String userBookId,
    required String settingsHash,
    required String viewport,
    required int fontsVersion,
    required Uint8List breaks,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : userBookId = Value(userBookId),
       settingsHash = Value(settingsHash),
       viewport = Value(viewport),
       fontsVersion = Value(fontsVersion),
       breaks = Value(breaks),
       createdAt = Value(createdAt);
  static Insertable<PageLayoutCacheRow> custom({
    Expression<String>? userBookId,
    Expression<String>? settingsHash,
    Expression<String>? viewport,
    Expression<int>? fontsVersion,
    Expression<Uint8List>? breaks,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userBookId != null) 'user_book_id': userBookId,
      if (settingsHash != null) 'settings_hash': settingsHash,
      if (viewport != null) 'viewport': viewport,
      if (fontsVersion != null) 'fonts_version': fontsVersion,
      if (breaks != null) 'breaks': breaks,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PageLayoutCacheCompanion copyWith({
    Value<String>? userBookId,
    Value<String>? settingsHash,
    Value<String>? viewport,
    Value<int>? fontsVersion,
    Value<Uint8List>? breaks,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PageLayoutCacheCompanion(
      userBookId: userBookId ?? this.userBookId,
      settingsHash: settingsHash ?? this.settingsHash,
      viewport: viewport ?? this.viewport,
      fontsVersion: fontsVersion ?? this.fontsVersion,
      breaks: breaks ?? this.breaks,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userBookId.present) {
      map['user_book_id'] = Variable<String>(userBookId.value);
    }
    if (settingsHash.present) {
      map['settings_hash'] = Variable<String>(settingsHash.value);
    }
    if (viewport.present) {
      map['viewport'] = Variable<String>(viewport.value);
    }
    if (fontsVersion.present) {
      map['fonts_version'] = Variable<int>(fontsVersion.value);
    }
    if (breaks.present) {
      map['breaks'] = Variable<Uint8List>(breaks.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $PageLayoutCacheTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PageLayoutCacheCompanion(')
          ..write('userBookId: $userBookId, ')
          ..write('settingsHash: $settingsHash, ')
          ..write('viewport: $viewport, ')
          ..write('fontsVersion: $fontsVersion, ')
          ..write('breaks: $breaks, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogCacheTable extends CatalogCache
    with TableInfo<$CatalogCacheTable, CatalogCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
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
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licenseMeta = const VerificationMeta(
    'license',
  );
  @override
  late final GeneratedColumn<String> license = GeneratedColumn<String>(
    'license',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> fetchedAt =
      GeneratedColumn<String>(
        'fetched_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CatalogCacheTable.$converterfetchedAt);
  @override
  List<GeneratedColumn> get $columns => [
    key,
    kind,
    source,
    license,
    payload,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('license')) {
      context.handle(
        _licenseMeta,
        license.isAcceptableOrUnknown(data['license']!, _licenseMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  CatalogCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogCacheRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      license: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      fetchedAt: $CatalogCacheTable.$converterfetchedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fetched_at'],
        )!,
      ),
    );
  }

  @override
  $CatalogCacheTable createAlias(String alias) {
    return $CatalogCacheTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterfetchedAt =
      const InstantConverter();
  @override
  bool get isStrict => true;
}

class CatalogCacheRow extends DataClass implements Insertable<CatalogCacheRow> {
  final String key;
  final String kind;
  final String source;
  final String? license;
  final String payload;
  final DateTime fetchedAt;
  const CatalogCacheRow({
    required this.key,
    required this.kind,
    required this.source,
    this.license,
    required this.payload,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['kind'] = Variable<String>(kind);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || license != null) {
      map['license'] = Variable<String>(license);
    }
    map['payload'] = Variable<String>(payload);
    {
      map['fetched_at'] = Variable<String>(
        $CatalogCacheTable.$converterfetchedAt.toSql(fetchedAt),
      );
    }
    return map;
  }

  CatalogCacheCompanion toCompanion(bool nullToAbsent) {
    return CatalogCacheCompanion(
      key: Value(key),
      kind: Value(kind),
      source: Value(source),
      license: license == null && nullToAbsent
          ? const Value.absent()
          : Value(license),
      payload: Value(payload),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CatalogCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogCacheRow(
      key: serializer.fromJson<String>(json['key']),
      kind: serializer.fromJson<String>(json['kind']),
      source: serializer.fromJson<String>(json['source']),
      license: serializer.fromJson<String?>(json['license']),
      payload: serializer.fromJson<String>(json['payload']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'kind': serializer.toJson<String>(kind),
      'source': serializer.toJson<String>(source),
      'license': serializer.toJson<String?>(license),
      'payload': serializer.toJson<String>(payload),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  CatalogCacheRow copyWith({
    String? key,
    String? kind,
    String? source,
    Value<String?> license = const Value.absent(),
    String? payload,
    DateTime? fetchedAt,
  }) => CatalogCacheRow(
    key: key ?? this.key,
    kind: kind ?? this.kind,
    source: source ?? this.source,
    license: license.present ? license.value : this.license,
    payload: payload ?? this.payload,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  CatalogCacheRow copyWithCompanion(CatalogCacheCompanion data) {
    return CatalogCacheRow(
      key: data.key.present ? data.key.value : this.key,
      kind: data.kind.present ? data.kind.value : this.kind,
      source: data.source.present ? data.source.value : this.source,
      license: data.license.present ? data.license.value : this.license,
      payload: data.payload.present ? data.payload.value : this.payload,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCacheRow(')
          ..write('key: $key, ')
          ..write('kind: $kind, ')
          ..write('source: $source, ')
          ..write('license: $license, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(key, kind, source, license, payload, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogCacheRow &&
          other.key == this.key &&
          other.kind == this.kind &&
          other.source == this.source &&
          other.license == this.license &&
          other.payload == this.payload &&
          other.fetchedAt == this.fetchedAt);
}

class CatalogCacheCompanion extends UpdateCompanion<CatalogCacheRow> {
  final Value<String> key;
  final Value<String> kind;
  final Value<String> source;
  final Value<String?> license;
  final Value<String> payload;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const CatalogCacheCompanion({
    this.key = const Value.absent(),
    this.kind = const Value.absent(),
    this.source = const Value.absent(),
    this.license = const Value.absent(),
    this.payload = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogCacheCompanion.insert({
    required String key,
    required String kind,
    required String source,
    this.license = const Value.absent(),
    required String payload,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       kind = Value(kind),
       source = Value(source),
       payload = Value(payload),
       fetchedAt = Value(fetchedAt);
  static Insertable<CatalogCacheRow> custom({
    Expression<String>? key,
    Expression<String>? kind,
    Expression<String>? source,
    Expression<String>? license,
    Expression<String>? payload,
    Expression<String>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (kind != null) 'kind': kind,
      if (source != null) 'source': source,
      if (license != null) 'license': license,
      if (payload != null) 'payload': payload,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogCacheCompanion copyWith({
    Value<String>? key,
    Value<String>? kind,
    Value<String>? source,
    Value<String?>? license,
    Value<String>? payload,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return CatalogCacheCompanion(
      key: key ?? this.key,
      kind: kind ?? this.kind,
      source: source ?? this.source,
      license: license ?? this.license,
      payload: payload ?? this.payload,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (license.present) {
      map['license'] = Variable<String>(license.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<String>(
        $CatalogCacheTable.$converterfetchedAt.toSql(fetchedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCacheCompanion(')
          ..write('key: $key, ')
          ..write('kind: $kind, ')
          ..write('source: $source, ')
          ..write('license: $license, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SocialCacheTable extends SocialCache
    with TableInfo<$SocialCacheTable, SocialCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SocialCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SocialCacheTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [key, payload, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'social_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<SocialCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SocialCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SocialCacheRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: $SocialCacheTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $SocialCacheTable createAlias(String alias) {
    return $SocialCacheTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterupdatedAt =
      const InstantConverter();
  @override
  bool get isStrict => true;
}

class SocialCacheRow extends DataClass implements Insertable<SocialCacheRow> {
  final String key;
  final String payload;
  final DateTime updatedAt;
  const SocialCacheRow({
    required this.key,
    required this.payload,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['payload'] = Variable<String>(payload);
    {
      map['updated_at'] = Variable<String>(
        $SocialCacheTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  SocialCacheCompanion toCompanion(bool nullToAbsent) {
    return SocialCacheCompanion(
      key: Value(key),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory SocialCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SocialCacheRow(
      key: serializer.fromJson<String>(json['key']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SocialCacheRow copyWith({
    String? key,
    String? payload,
    DateTime? updatedAt,
  }) => SocialCacheRow(
    key: key ?? this.key,
    payload: payload ?? this.payload,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SocialCacheRow copyWithCompanion(SocialCacheCompanion data) {
    return SocialCacheRow(
      key: data.key.present ? data.key.value : this.key,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SocialCacheRow(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SocialCacheRow &&
          other.key == this.key &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class SocialCacheCompanion extends UpdateCompanion<SocialCacheRow> {
  final Value<String> key;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SocialCacheCompanion({
    this.key = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SocialCacheCompanion.insert({
    required String key,
    required String payload,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<SocialCacheRow> custom({
    Expression<String>? key,
    Expression<String>? payload,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SocialCacheCompanion copyWith({
    Value<String>? key,
    Value<String>? payload,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SocialCacheCompanion(
      key: key ?? this.key,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $SocialCacheTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SocialCacheCompanion(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingSocialOpsTable extends PendingSocialOps
    with TableInfo<$PendingSocialOpsTable, PendingSocialOpRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingSocialOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PendingSocialOpsTable.$convertercreatedAt);
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    op,
    payload,
    createdAt,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_social_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingSocialOpRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingSocialOpRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingSocialOpRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: $PendingSocialOpsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $PendingSocialOpsTable createAlias(String alias) {
    return $PendingSocialOpsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const InstantConverter();
  @override
  bool get isStrict => true;
}

class PendingSocialOpRow extends DataClass
    implements Insertable<PendingSocialOpRow> {
  final String id;
  final String op;
  final String payload;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;
  const PendingSocialOpRow({
    required this.id,
    required this.op,
    required this.payload,
    required this.createdAt,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['op'] = Variable<String>(op);
    map['payload'] = Variable<String>(payload);
    {
      map['created_at'] = Variable<String>(
        $PendingSocialOpsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  PendingSocialOpsCompanion toCompanion(bool nullToAbsent) {
    return PendingSocialOpsCompanion(
      id: Value(id),
      op: Value(op),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory PendingSocialOpRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingSocialOpRow(
      id: serializer.fromJson<String>(json['id']),
      op: serializer.fromJson<String>(json['op']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'op': serializer.toJson<String>(op),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  PendingSocialOpRow copyWith({
    String? id,
    String? op,
    String? payload,
    DateTime? createdAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => PendingSocialOpRow(
    id: id ?? this.id,
    op: op ?? this.op,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  PendingSocialOpRow copyWithCompanion(PendingSocialOpsCompanion data) {
    return PendingSocialOpRow(
      id: data.id.present ? data.id.value : this.id,
      op: data.op.present ? data.op.value : this.op,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingSocialOpRow(')
          ..write('id: $id, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, op, payload, createdAt, attempts, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingSocialOpRow &&
          other.id == this.id &&
          other.op == this.op &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class PendingSocialOpsCompanion extends UpdateCompanion<PendingSocialOpRow> {
  final Value<String> id;
  final Value<String> op;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<int> rowid;
  const PendingSocialOpsCompanion({
    this.id = const Value.absent(),
    this.op = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingSocialOpsCompanion.insert({
    required String id,
    required String op,
    required String payload,
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       op = Value(op),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<PendingSocialOpRow> custom({
    Expression<String>? id,
    Expression<String>? op,
    Expression<String>? payload,
    Expression<String>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (op != null) 'op': op,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingSocialOpsCompanion copyWith({
    Value<String>? id,
    Value<String>? op,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return PendingSocialOpsCompanion(
      id: id ?? this.id,
      op: op ?? this.op,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $PendingSocialOpsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingSocialOpsCompanion(')
          ..write('id: $id, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncRejectionsTable extends SyncRejections
    with TableInfo<$SyncRejectionsTable, SyncRejectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncRejectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> rejectedAt =
      GeneratedColumn<String>(
        'rejected_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SyncRejectionsTable.$converterrejectedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entity,
    rowId,
    reason,
    code,
    operation,
    rejectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_rejections';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncRejectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncRejectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncRejectionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      rejectedAt: $SyncRejectionsTable.$converterrejectedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rejected_at'],
        )!,
      ),
    );
  }

  @override
  $SyncRejectionsTable createAlias(String alias) {
    return $SyncRejectionsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterrejectedAt =
      const InstantConverter();
  @override
  bool get isStrict => true;
}

class SyncRejectionRow extends DataClass
    implements Insertable<SyncRejectionRow> {
  final String id;

  /// Tabela pessoal da linha (`user_books`, `annotations`…).
  final String entity;
  final String rowId;
  final String reason;
  final String? code;
  final String operation;
  final DateTime rejectedAt;
  const SyncRejectionRow({
    required this.id,
    required this.entity,
    required this.rowId,
    required this.reason,
    this.code,
    required this.operation,
    required this.rejectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity'] = Variable<String>(entity);
    map['row_id'] = Variable<String>(rowId);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['operation'] = Variable<String>(operation);
    {
      map['rejected_at'] = Variable<String>(
        $SyncRejectionsTable.$converterrejectedAt.toSql(rejectedAt),
      );
    }
    return map;
  }

  SyncRejectionsCompanion toCompanion(bool nullToAbsent) {
    return SyncRejectionsCompanion(
      id: Value(id),
      entity: Value(entity),
      rowId: Value(rowId),
      reason: Value(reason),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      operation: Value(operation),
      rejectedAt: Value(rejectedAt),
    );
  }

  factory SyncRejectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncRejectionRow(
      id: serializer.fromJson<String>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      rowId: serializer.fromJson<String>(json['rowId']),
      reason: serializer.fromJson<String>(json['reason']),
      code: serializer.fromJson<String?>(json['code']),
      operation: serializer.fromJson<String>(json['operation']),
      rejectedAt: serializer.fromJson<DateTime>(json['rejectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entity': serializer.toJson<String>(entity),
      'rowId': serializer.toJson<String>(rowId),
      'reason': serializer.toJson<String>(reason),
      'code': serializer.toJson<String?>(code),
      'operation': serializer.toJson<String>(operation),
      'rejectedAt': serializer.toJson<DateTime>(rejectedAt),
    };
  }

  SyncRejectionRow copyWith({
    String? id,
    String? entity,
    String? rowId,
    String? reason,
    Value<String?> code = const Value.absent(),
    String? operation,
    DateTime? rejectedAt,
  }) => SyncRejectionRow(
    id: id ?? this.id,
    entity: entity ?? this.entity,
    rowId: rowId ?? this.rowId,
    reason: reason ?? this.reason,
    code: code.present ? code.value : this.code,
    operation: operation ?? this.operation,
    rejectedAt: rejectedAt ?? this.rejectedAt,
  );
  SyncRejectionRow copyWithCompanion(SyncRejectionsCompanion data) {
    return SyncRejectionRow(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      reason: data.reason.present ? data.reason.value : this.reason,
      code: data.code.present ? data.code.value : this.code,
      operation: data.operation.present ? data.operation.value : this.operation,
      rejectedAt: data.rejectedAt.present
          ? data.rejectedAt.value
          : this.rejectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncRejectionRow(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('reason: $reason, ')
          ..write('code: $code, ')
          ..write('operation: $operation, ')
          ..write('rejectedAt: $rejectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entity, rowId, reason, code, operation, rejectedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncRejectionRow &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.rowId == this.rowId &&
          other.reason == this.reason &&
          other.code == this.code &&
          other.operation == this.operation &&
          other.rejectedAt == this.rejectedAt);
}

class SyncRejectionsCompanion extends UpdateCompanion<SyncRejectionRow> {
  final Value<String> id;
  final Value<String> entity;
  final Value<String> rowId;
  final Value<String> reason;
  final Value<String?> code;
  final Value<String> operation;
  final Value<DateTime> rejectedAt;
  final Value<int> rowid;
  const SyncRejectionsCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.rowId = const Value.absent(),
    this.reason = const Value.absent(),
    this.code = const Value.absent(),
    this.operation = const Value.absent(),
    this.rejectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncRejectionsCompanion.insert({
    required String id,
    required String entity,
    required String rowId,
    required String reason,
    this.code = const Value.absent(),
    required String operation,
    required DateTime rejectedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entity = Value(entity),
       rowId = Value(rowId),
       reason = Value(reason),
       operation = Value(operation),
       rejectedAt = Value(rejectedAt);
  static Insertable<SyncRejectionRow> custom({
    Expression<String>? id,
    Expression<String>? entity,
    Expression<String>? rowId,
    Expression<String>? reason,
    Expression<String>? code,
    Expression<String>? operation,
    Expression<String>? rejectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (rowId != null) 'row_id': rowId,
      if (reason != null) 'reason': reason,
      if (code != null) 'code': code,
      if (operation != null) 'operation': operation,
      if (rejectedAt != null) 'rejected_at': rejectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncRejectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? entity,
    Value<String>? rowId,
    Value<String>? reason,
    Value<String?>? code,
    Value<String>? operation,
    Value<DateTime>? rejectedAt,
    Value<int>? rowid,
  }) {
    return SyncRejectionsCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      rowId: rowId ?? this.rowId,
      reason: reason ?? this.reason,
      code: code ?? this.code,
      operation: operation ?? this.operation,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (rejectedAt.present) {
      map['rejected_at'] = Variable<String>(
        $SyncRejectionsTable.$converterrejectedAt.toSql(rejectedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncRejectionsCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('reason: $reason, ')
          ..write('code: $code, ')
          ..write('operation: $operation, ')
          ..write('rejectedAt: $rejectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncIgnoredDeletesTable extends SyncIgnoredDeletes
    with TableInfo<$SyncIgnoredDeletesTable, SyncIgnoredDeleteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncIgnoredDeletesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<String> receivedAt = GeneratedColumn<String>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [seq, entity, rowId, receivedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_ignored_deletes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncIgnoredDeleteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  SyncIgnoredDeleteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncIgnoredDeleteRow(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}received_at'],
      )!,
    );
  }

  @override
  $SyncIgnoredDeletesTable createAlias(String alias) {
    return $SyncIgnoredDeletesTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class SyncIgnoredDeleteRow extends DataClass
    implements Insertable<SyncIgnoredDeleteRow> {
  final int seq;

  /// Tabela pessoal da linha (`user_books`, `annotations`…).
  final String entity;
  final String rowId;
  final String receivedAt;
  const SyncIgnoredDeleteRow({
    required this.seq,
    required this.entity,
    required this.rowId,
    required this.receivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['entity'] = Variable<String>(entity);
    map['row_id'] = Variable<String>(rowId);
    map['received_at'] = Variable<String>(receivedAt);
    return map;
  }

  SyncIgnoredDeletesCompanion toCompanion(bool nullToAbsent) {
    return SyncIgnoredDeletesCompanion(
      seq: Value(seq),
      entity: Value(entity),
      rowId: Value(rowId),
      receivedAt: Value(receivedAt),
    );
  }

  factory SyncIgnoredDeleteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncIgnoredDeleteRow(
      seq: serializer.fromJson<int>(json['seq']),
      entity: serializer.fromJson<String>(json['entity']),
      rowId: serializer.fromJson<String>(json['rowId']),
      receivedAt: serializer.fromJson<String>(json['receivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'entity': serializer.toJson<String>(entity),
      'rowId': serializer.toJson<String>(rowId),
      'receivedAt': serializer.toJson<String>(receivedAt),
    };
  }

  SyncIgnoredDeleteRow copyWith({
    int? seq,
    String? entity,
    String? rowId,
    String? receivedAt,
  }) => SyncIgnoredDeleteRow(
    seq: seq ?? this.seq,
    entity: entity ?? this.entity,
    rowId: rowId ?? this.rowId,
    receivedAt: receivedAt ?? this.receivedAt,
  );
  SyncIgnoredDeleteRow copyWithCompanion(SyncIgnoredDeletesCompanion data) {
    return SyncIgnoredDeleteRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      entity: data.entity.present ? data.entity.value : this.entity,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncIgnoredDeleteRow(')
          ..write('seq: $seq, ')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seq, entity, rowId, receivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncIgnoredDeleteRow &&
          other.seq == this.seq &&
          other.entity == this.entity &&
          other.rowId == this.rowId &&
          other.receivedAt == this.receivedAt);
}

class SyncIgnoredDeletesCompanion
    extends UpdateCompanion<SyncIgnoredDeleteRow> {
  final Value<int> seq;
  final Value<String> entity;
  final Value<String> rowId;
  final Value<String> receivedAt;
  const SyncIgnoredDeletesCompanion({
    this.seq = const Value.absent(),
    this.entity = const Value.absent(),
    this.rowId = const Value.absent(),
    this.receivedAt = const Value.absent(),
  });
  SyncIgnoredDeletesCompanion.insert({
    this.seq = const Value.absent(),
    required String entity,
    required String rowId,
    required String receivedAt,
  }) : entity = Value(entity),
       rowId = Value(rowId),
       receivedAt = Value(receivedAt);
  static Insertable<SyncIgnoredDeleteRow> custom({
    Expression<int>? seq,
    Expression<String>? entity,
    Expression<String>? rowId,
    Expression<String>? receivedAt,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (entity != null) 'entity': entity,
      if (rowId != null) 'row_id': rowId,
      if (receivedAt != null) 'received_at': receivedAt,
    });
  }

  SyncIgnoredDeletesCompanion copyWith({
    Value<int>? seq,
    Value<String>? entity,
    Value<String>? rowId,
    Value<String>? receivedAt,
  }) {
    return SyncIgnoredDeletesCompanion(
      seq: seq ?? this.seq,
      entity: entity ?? this.entity,
      rowId: rowId ?? this.rowId,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<String>(receivedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncIgnoredDeletesCompanion(')
          ..write('seq: $seq, ')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $UserBooksTable userBooks = $UserBooksTable(this);
  late final $ReadingPositionsTable readingPositions = $ReadingPositionsTable(
    this,
  );
  late final $ReadingSessionsTable readingSessions = $ReadingSessionsTable(
    this,
  );
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $InkLayersTable inkLayers = $InkLayersTable(this);
  late final $AnnotationsTable annotations = $AnnotationsTable(this);
  late final $HighlightLabelsTable highlightLabels = $HighlightLabelsTable(
    this,
  );
  late final $ReaderSettingsRowsTable readerSettingsRows =
      $ReaderSettingsRowsTable(this);
  late final $PenPresetsRowsTable penPresetsRows = $PenPresetsRowsTable(this);
  late final $ReadingGoalsRowsTable readingGoalsRows = $ReadingGoalsRowsTable(
    this,
  );
  late final $KvTable kv = $KvTable(this);
  late final $LocalFilesTable localFiles = $LocalFilesTable(this);
  late final $BookContentIndexTable bookContentIndex = $BookContentIndexTable(
    this,
  );
  late final $PageLayoutCacheTable pageLayoutCache = $PageLayoutCacheTable(
    this,
  );
  late final $CatalogCacheTable catalogCache = $CatalogCacheTable(this);
  late final $SocialCacheTable socialCache = $SocialCacheTable(this);
  late final $PendingSocialOpsTable pendingSocialOps = $PendingSocialOpsTable(
    this,
  );
  late final $SyncRejectionsTable syncRejections = $SyncRejectionsTable(this);
  late final $SyncIgnoredDeletesTable syncIgnoredDeletes =
      $SyncIgnoredDeletesTable(this);
  late final Index userBooksUserIdx = Index(
    'user_books_user_idx',
    'CREATE INDEX user_books_user_idx ON user_books (user_id, updated_at)',
  );
  late final Index userBooksUserIsbnIdx = Index(
    'user_books_user_isbn_idx',
    'CREATE INDEX user_books_user_isbn_idx ON user_books (user_id, isbn13)',
  );
  late final Index readingSessionsBookIdx = Index(
    'reading_sessions_book_idx',
    'CREATE INDEX reading_sessions_book_idx ON reading_sessions (user_book_id)',
  );
  late final Index readingSessionsStartedIdx = Index(
    'reading_sessions_started_idx',
    'CREATE INDEX reading_sessions_started_idx ON reading_sessions (started_at)',
  );
  late final Index bookmarksBookIdx = Index(
    'bookmarks_book_idx',
    'CREATE INDEX bookmarks_book_idx ON bookmarks (user_book_id, ref_page)',
  );
  late final Index inkLayersBookIdx = Index(
    'ink_layers_book_idx',
    'CREATE INDEX ink_layers_book_idx ON ink_layers (user_book_id)',
  );
  late final Index annotationsBookPageIdx = Index(
    'annotations_book_page_idx',
    'CREATE INDEX annotations_book_page_idx ON annotations (user_book_id, ref_page)',
  );
  late final Index annotationsParentIdx = Index(
    'annotations_parent_idx',
    'CREATE INDEX annotations_parent_idx ON annotations (parent_id)',
  );
  late final Index annotationsInkIdx = Index(
    'annotations_ink_idx',
    'CREATE INDEX annotations_ink_idx ON annotations (ink_layer_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userBooks,
    readingPositions,
    readingSessions,
    bookmarks,
    inkLayers,
    annotations,
    highlightLabels,
    readerSettingsRows,
    penPresetsRows,
    readingGoalsRows,
    kv,
    localFiles,
    bookContentIndex,
    pageLayoutCache,
    catalogCache,
    socialCache,
    pendingSocialOps,
    syncRejections,
    syncIgnoredDeletes,
    userBooksUserIdx,
    userBooksUserIsbnIdx,
    readingSessionsBookIdx,
    readingSessionsStartedIdx,
    bookmarksBookIdx,
    inkLayersBookIdx,
    annotationsBookPageIdx,
    annotationsParentIdx,
    annotationsInkIdx,
  ];
}
