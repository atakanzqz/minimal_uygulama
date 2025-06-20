import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minimal_uygulama/models/urunler_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UrunlerModel? _veriler;
  List<Urun> _urunler = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final dataString = await rootBundle.loadString('assets/files/data.json');
      final dataJson = jsonDecode(dataString);
      final veriler = UrunlerModel.fromJson(dataJson);

      if (!mounted) return;

      setState(() {
        _veriler = veriler;
        _urunler = veriler.urunler;
      });
    } catch (e) {
      debugPrint("Veri yüklenirken hata oluştu: $e");
    }
  }

  void _filterData(int id) {
    if (_veriler == null) return;

    setState(() {
      _urunler = _veriler!.urunler
          .where((item) => item.kategori == id)
          .toList();
    });
  }

  void _resetFilter() {
    if (_veriler == null) return;

    setState(() {
      _urunler = _veriler!.urunler;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ürün Listesi")),
      body: _veriler == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(38, 192, 9, 180), // %21 siyah
                    Color.fromARGB(54, 255, 0, 0), // %50 kırmızı
                    Color.fromARGB(
                      99,
                      255,
                      0,
                      0,
                    ), // %100 kırmızı (aynı renk sabit bitiş)
                  ],
                  stops: [
                    0.20, // %21
                    0.8, // %50
                    2.0, // %100
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _resetFilter,
                    child: const Text('Tüm Ürünler'),
                  ),
                  _kategorilerView(),
                  Expanded(child: _urunlerView()),
                ],
              ),
            ),
    );
  }

  Widget _urunlerView() {
    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: _urunler.length,
      itemBuilder: (context, index) {
        final urun = _urunler[index];
        return Padding(
          padding: const EdgeInsets.all(8.2),
          child: ListTile(
            leading: Image.network(
              urun.resim,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported),
            ),
            title: Text(urun.isim),
            subtitle: 1 == urun.kategori
                ? Text("Meyve")
                : 2 == urun.kategori
                ? Text("Yemek")
                : Text("İçecek"),
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 10),
    );
  }

  Widget _kategorilerView() {
    if (_veriler == null) return const SizedBox();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: _veriler!.kategoriler.map((kategori) {
          return GestureDetector(
            onTap: () => _filterData(kategori.id),
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(kategori.isim),
            ),
          );
        }).toList(),
      ),
    );
  }
}
