// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookProgressAdapter extends TypeAdapter<BookProgress> {
  @override
  final int typeId = 1;

  @override
  BookProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookProgress(
      id: fields[0] as String,
      bookId: fields[1] as String,
      title: fields[2] as String,
      pdfPath: fields[3] as String,
      lastPage: fields[4] as int,
      zoomLevel: fields[5] as double,
      addedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BookProgress obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bookId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.pdfPath)
      ..writeByte(4)
      ..write(obj.lastPage)
      ..writeByte(5)
      ..write(obj.zoomLevel)
      ..writeByte(6)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
