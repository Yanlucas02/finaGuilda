import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'transacao.dart';

void main() {
  runApp(const MaterialApp(
    title: 'FinanGuilda',
    home: FinanGuildaApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class FinanGuildaApp extends StatefulWidget {
  const FinanGuildaApp({super.key});

  @override
  State<FinanGuildaApp> createState() => _FinanGuildaAppState();
}

class _FinanGuildaAppState extends State<FinanGuildaApp> {
  // Configuração da URL da API:
  // - No FlutLab ou Web/Chrome local: 'http://localhost:8080/api/transacoes&#39;
  // - Em dispositivo físico via Wi-Fi: 'http://192.168.X.X:8080/api/transacoes&#39;
  final String baseUrl = 'https://obvious-flashbulb-unshaven.ngrok-free.dev';

  List<Transacao> _transacoes = [];
  ResumoFinanceiro _resumo =
      ResumoFinanceiro(totalReceitas: 0.0, totalDespesas: 0.0, saldo: 0.0);
  bool _carregando = false;

  // Controladores do formulário
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  String _tipoSelecionado = 'RECEITA';
  String _categoriaSelecionada = 'Alimentação';

  final List<String> _categorias = [
    'Alimentação',
    'Transporte',
    'Lazer',
    'Serviços',
    'Educação',
    'Geral'
  ];

  @override
  void initState() {
    super.initState();
    _atualizarDados();
  }

  @override
  void dispose() {
    _descController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  // Requisições GET (Lista de Transações e Resumo Calculado)
  Future<void> _atualizarDados() async {
    setState(() => _carregando = true);

    try {
      // Cabeçalho obrigatório para ignorar a página de aviso do ngrok gratuito
      final cabecalhosNgrok = {
        'ngrok-skip-browser-warning': 'true',
      };

      final resLista = await http.get(
        Uri.parse(baseUrl.trim()),
        headers: cabecalhosNgrok,
      );

      final resResumo = await http.get(
        Uri.parse('${baseUrl.trim()}/resumo'),
        headers: cabecalhosNgrok,
      );

      if (resLista.statusCode == 200 && resResumo.statusCode == 200) {
        final List<dynamic> listaJson =
            jsonDecode(utf8.decode(resLista.bodyBytes));
        final Map<String, dynamic> resumoJson =
            jsonDecode(utf8.decode(resResumo.bodyBytes));

        setState(() {
          _transacoes =
              listaJson.map((item) => Transacao.fromJson(item)).toList();
          _resumo = ResumoFinanceiro.fromJson(resumoJson);
        });
      } else {
        throw Exception(
            'Código de resposta do servidor: ${resLista.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha na comunicação com o Java: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // Requisição POST (Envio de Nova Transação)
  Future<void> _cadastrarTransacao() async {
    final descricao = _descController.text.trim();
    final valor =
        double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;

    if (descricao.length < 3 || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Descrição mínima de 3 caracteres e valor superior a zero!'),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }

    final payload = {
      'descricao': descricao,
      'valor': valor,
      'tipo': _tipoSelecionado,
      'categoria': _categoriaSelecionada,
    };

    try {
      final resposta = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(payload),
      );

      if (resposta.statusCode == 201) {
        _descController.clear();
        _valorController.clear();

        if (mounted) {
          Navigator.pop(context); // Fecha a folha modal
          _atualizarDados(); // Atualiza a lista e o saldo recalculado pelo Java
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Movimentação guardada com sucesso!'),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      } else {
        throw Exception('Erro ${resposta.statusCode}: ${resposta.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar movimentação: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // Formulário Modal Inferior
  void _abrirModalCadastro() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Novo Lançamento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Descrição (ex: Bolsas, Cantina)',
                  prefixIcon: const Icon(Icons.edit_note),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _valorController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Valor monetário (R\$)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _tipoSelecionado,
                      decoration: InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'RECEITA', child: Text('RECEITA')),
                        DropdownMenuItem(
                            value: 'DESPESA', child: Text('DESPESA')),
                      ],
                      onChanged: (val) {
                        if (val != null)
                          setModalState(() => _tipoSelecionado = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _categoriaSelecionada,
                      decoration: InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      items: _categorias
                          .map((cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null)
                          setModalState(() => _categoriaSelecionada = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _cadastrarTransacao,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirmar Registo',
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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
    final bool saldoPositivo = _resumo.saldo >= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinanGuilda — Mobile'),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _atualizarDados,
            tooltip: 'Atualizar Dados',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirModalCadastro,
        backgroundColor: Colors.indigo.shade800,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _atualizarDados,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                children: [
                  // CARD DE SALDO CONSOLIDADO
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    color: saldoPositivo
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            'Saldo Consolidado',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'R\$ ${_resumo.saldo.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: saldoPositivo
                                  ? Colors.green.shade900
                                  : Colors.red.shade900,
                            ),
                          ),
                          const Divider(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('Receitas',
                                      style: TextStyle(color: Colors.black54)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '+ R\$ ${_resumo.totalReceitas.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                  width: 1, height: 35, color: Colors.black12),
                              Column(
                                children: [
                                  const Text('Despesas',
                                      style: TextStyle(color: Colors.black54)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '- R\$ ${_resumo.totalDespesas.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Histórico de Lançamentos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // LISTAGEM DE LANÇAMENTOS OU ESTADO VAZIO
                  if (_transacoes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'Nenhuma transação registada na API Java.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  else
                    ..._transacoes.map((t) {
                      final bool isReceita = t.tipo == 'RECEITA';
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isReceita
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            child: Icon(
                              isReceita
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: isReceita
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                          title: Text(
                            t.descricao,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(t.categoria),
                          trailing: Text(
                            '${isReceita ? "+ " : "- "}R\$ ${t.valor.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isReceita
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }
}
