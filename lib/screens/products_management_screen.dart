import 'package:flutter/material.dart';
import '../database/db_helder.dart';
import '../models/product.dart';
import 'home_screen.dart';

class ProductsManagementScreen extends StatefulWidget {
  static const routeName = '/products-management';

  const ProductsManagementScreen({super.key});

  @override
  State<ProductsManagementScreen> createState() => _ProductsManagementScreenState();
}

class _ProductsManagementScreenState extends State<ProductsManagementScreen> {
  late Future<List<Product>> _productsFuture;
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  Product? _editingProduct;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _productsFuture = DBHelper.instance.getProducts();
  }

  void _resetForm() {
    _nomeController.clear();
    _descricaoController.clear();
    _precoController.clear();
    _editingProduct = null;
  }

  void _editProduct(Product product) {
    _editingProduct = product;
    _nomeController.text = product.nome;
    _descricaoController.text = product.descricao;
    _precoController.text = product.preco.toStringAsFixed(2);
    _showProductForm();
  }

  void _deleteProduct(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja deletar este produto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              await DBHelper.instance.deleteProduct(id);
              if (mounted) {
                navigator.pop();
                setState(_loadProducts);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Produto deletado com sucesso!')),
                  );
                }
              }
            },
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      final nome = _nomeController.text.trim();
      final descricao = _descricaoController.text.trim();
      final preco = double.parse(_precoController.text.trim());

      if (_editingProduct != null) {
        // Atualizar produto
        final updatedProduct = Product(
          id: _editingProduct!.id,
          nome: nome,
          descricao: descricao,
          preco: preco,
        );
        await DBHelper.instance.updateProduct(updatedProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produto atualizado com sucesso!')),
          );
        }
      } else {
        // Inserir novo produto
        final newProduct = Product(
          nome: nome,
          descricao: descricao,
          preco: preco,
        );
        await DBHelper.instance.insertProduct(newProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produto criado com sucesso!')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
        _resetForm();
        setState(_loadProducts);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar produto: $e')),
        );
      }
    }
  }

  void _showProductForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _editingProduct != null ? 'Editar Produto' : 'Novo Produto',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do produto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Preço',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o preço';
                  }
                  try {
                    double.parse(value.trim());
                  } catch (e) {
                    return 'Preço inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(_editingProduct != null ? 'Atualizar' : 'Criar'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _resetForm();
                  },
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Produtos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, HomeScreen.routeName),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nenhum produto encontrado'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _resetForm();
                      _showProductForm();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Criar Produto'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(product.nome),
                  subtitle: Text(
                    'R\$ ${product.preco.toStringAsFixed(2)}\n${product.descricao}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => _editProduct(product),
                        child: const Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () => _deleteProduct(product.id!),
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Deletar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _resetForm();
          _showProductForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }
}
