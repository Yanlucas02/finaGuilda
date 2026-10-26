class Transacao {
  final int id;
  final String descricao;
  final double valor;
  final String tipo; // "RECEITA" ou "DESPESA"
  final String categoria;

  Transacao({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.categoria,
  });

  factory Transacao.fromJson(Map<String, dynamic> json) {
    return Transacao(
      id: json['id'] as int? ?? 0,
      descricao: json['descricao']?.toString() ?? 'Sem descrição',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      tipo: json['tipo']?.toString().toUpperCase() ?? 'DESPESA',
      categoria: json['categoria']?.toString() ?? 'Geral',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'descricao': descricao,
      'valor': valor,
      'tipo': tipo,
      'categoria': categoria,
    };
  }
}

class ResumoFinanceiro {
  final double totalReceitas;
  final double totalDespesas;
  final double saldo;

  ResumoFinanceiro({
    required this.totalReceitas,
    required this.totalDespesas,
    required this.saldo,
  });

  factory ResumoFinanceiro.fromJson(Map<String, dynamic> json) {
    return ResumoFinanceiro(
      totalReceitas: (json['totalReceitas'] as num?)?.toDouble() ?? 0.0,
      totalDespesas: (json['totalDespesas'] as num?)?.toDouble() ?? 0.0,
      saldo: (json['saldo'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
