import 'package:flutter/material.dart';
import '../database/db_helder.dart';
import '../models/product.dart';
import 'details_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: DBHelper.instance.ensureSampleProducts().then((_) => DBHelper.instance.getProducts()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar produtos: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(child: Text('Nenhum produto encontrado.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (context, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: ListTile(
                  title: Text(product.nome),
                  subtitle: Text(product.descricao),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      DetailsScreen.routeName,
                      arguments: DetailArguments(
                        title: product.nome,
                        subtitle: product.descricao,
                        description: 'Preço: R\$ ${product.preco.toStringAsFixed(2)}\n\n${product.descricao}',
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
