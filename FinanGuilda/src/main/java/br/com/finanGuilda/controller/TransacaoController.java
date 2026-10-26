package br.com.finanGuilda.controller;

import br.com.finanGuilda.model.Transacao;
import br.com.finanGuilda.model.ResumoFinanceiro;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;

@RestController
@RequestMapping("/api/transacoes")
@CrossOrigin(origins = "*") // Permite chamadas do Flutter (FlutLab, Emulador ou Navegador)
public class TransacaoController {

    private final List<Transacao> bancoDados = new CopyOnWriteArrayList<>();
    private final AtomicInteger geradorId = new AtomicInteger(1);

    public TransacaoController() {
        // Dados de teste iniciais
        bancoDados.add(new Transacao(geradorId.getAndIncrement(), "Recompensa de Missão", 250.00, "RECEITA", "Serviços"));
        bancoDados.add(new Transacao(geradorId.getAndIncrement(), "Poção de Cura", 45.00, "DESPESA", "Suprimentos"));
    }

    @GetMapping
    public List<Transacao> listarTodas() {
        return bancoDados;
    }

    @GetMapping("/resumo")
    public ResumoFinanceiro obterResumo() {
        // Uso intensivo da Streams API
        double receitas = bancoDados.stream()
                .filter(t -> t.tipo().equalsIgnoreCase("RECEITA"))
                .mapToDouble(Transacao::valor)
                .sum();

        double despesas = bancoDados.stream()
                .filter(t -> t.tipo().equalsIgnoreCase("DESPESA"))
                .mapToDouble(Transacao::valor)
                .sum();

        return new ResumoFinanceiro(receitas, despesas, (receitas - despesas));
    }

    @PostMapping
    public ResponseEntity<Transacao> cadastrar(@RequestBody Transacao dados) {
        Transacao nova = new Transacao(
                geradorId.getAndIncrement(),
                dados.descricao(),
                dados.valor(),
                dados.tipo(),
                dados.categoria()
        );
        bancoDados.add(nova);
        return ResponseEntity.status(HttpStatus.CREATED).body(nova);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable int id) {
        boolean removido = bancoDados.removeIf(t -> t.id() == id);
        if (removido) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
