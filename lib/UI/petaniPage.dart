import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_pagination/models/petani_model.dart';
import 'package:flutter_pagination/service/apiPetani.dart';
import 'package:flutter_pagination/UI/petaniForm.dart';

class PagePetani extends StatefulWidget {
  const PagePetani({super.key});

  @override
  State<PagePetani> createState() => _PagePetaniState();
}

class _PagePetaniState extends State<PagePetani> {
  static const _pageSize = 5;

  final PagingController<int, Petani> _pagingController =
      PagingController(firstPageKey: 1);

  String _searchText = '';
  String _selectedAngkatan = '';

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await ApiStatic.getPetaniFilter(
        pageKey,
        _searchText,
        _selectedAngkatan,
        pageSize: _pageSize,
      );

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> _deletePetani(String idPenjual) async {
    final result = await ApiStatic.deletePetani(idPenjual);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result ? 'Data berhasil dihapus' : 'Gagal menghapus data'),
      ),
    );
    if (result) _pagingController.refresh();
  }

  Widget _buildPetaniItem(Petani petani) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        leading: ClipOval(
          child: petani.foto.isNotEmpty
              ? Image.network(
                  petani.foto,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person),
                )
              : const Icon(Icons.person, size: 60),
        ),
        title: Text(petani.nama.isNotEmpty ? petani.nama : 'Nama tidak tersedia'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NIK: ${petani.nik.isNotEmpty ? petani.nik : "-"}'),
            Text('Alamat: ${petani.alamat.isNotEmpty ? petani.alamat : "-"}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PetaniFormPage(petani: petani)),
              ).then((_) => _pagingController.refresh());
            } else if (value == 'delete') {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Konfirmasi"),
                  content: const Text("Yakin ingin menghapus data ini?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deletePetani(petani.idPenjual.toString());
                      },
                      child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Hapus')),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Cari Petani',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _searchText = value;
              _pagingController.refresh();
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedAngkatan,
            decoration: const InputDecoration(
              labelText: 'Angkatan',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: '', child: Text('Semua')),
              DropdownMenuItem(value: '22', child: Text('Angkatan 22')),
              DropdownMenuItem(value: '23', child: Text('Angkatan 23')),
              DropdownMenuItem(value: '24', child: Text('Angkatan 24')),
              DropdownMenuItem(value: '25', child: Text('Angkatan 25')),
            ],
            onChanged: (value) {
              _selectedAngkatan = value!;
              _pagingController.refresh();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Petani')),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: PagedListView<int, Petani>(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<Petani>(
                  itemBuilder: (context, item, index) => _buildPetaniItem(item),
                  firstPageProgressIndicatorBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  newPageProgressIndicatorBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  firstPageErrorIndicatorBuilder: (context) =>
                      const Center(child: Text('Gagal memuat data')),
                  noItemsFoundIndicatorBuilder: (context) =>
                      const Center(child: Text('Tidak ada data petani')),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PetaniFormPage()),
          ).then((_) => _pagingController.refresh());
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Petani',
      ),
    );
  }
}