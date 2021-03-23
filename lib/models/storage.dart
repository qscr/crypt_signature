import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage<T> {
  SharedPreferences prefs;
  T Function(Map) parser;

  Storage(this.parser) {
    _load();
  }

  _load() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<List<T>> get() async {
    List<dynamic> list = json.decode(prefs.getString(T.toString()));

    if (list == null || list.isEmpty) return [];

    List<T> objects = [];

    for (Map object in list) objects.add(await compute(parser, object));

    return objects;
  }

  Future save(List<T> objects) async {
    prefs.setString(T.toString(), json.encode(objects));
  }

  Future<bool> add(T object) async {
    List<T> objects = await this.get();

    if (objects.contains(object)) return false;

    objects.add(object);

    this.save(objects);

    return true;
  }

  Future<bool> remove(T object) async {
    List<T> objects = await this.get();

    if (!objects.contains(object)) return false;

    objects.remove(object);

    this.save(objects);

    return true;
  }
}
