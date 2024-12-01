#!/bin/bash

# Configurações gerais
OUTPUT_DIR="resultados"  # Diretório para salvar os resultados
NUM_CORES=$(nproc)       # Número de núcleos disponíveis no computador
NODES="node1,node2"      # Nós do cluster (ajuste conforme necessário)
PROGRAM_OPENMP="../mandelbrot_omp"  # Executável do OpenMP
PROGRAM_MPI="../mandelbrot_mpi"       # Executável do MPI

# Criar diretório de resultados
mkdir -p $OUTPUT_DIR

# Função para executar OpenMP com diferentes números de threads
run_openmp_tests() {
    echo "Executando testes para OpenMP..."
    for THREADS in $(seq 2 2 $NUM_CORES); do
        export OMP_NUM_THREADS=$THREADS  # Define o número de threads para OpenMP
        echo "Executando com $THREADS threads..."
        START_TIME=$(date +%s%N)  # Início do temporizador
        $PROGRAM_OPENMP > "$OUTPUT_DIR/openmp_${THREADS}_threads.txt"
        END_TIME=$(date +%s%N)    # Fim do temporizador
        ELAPSED_TIME=$((($END_TIME - $START_TIME) / 1000000))  # Tempo em milissegundos
        echo "Tempo de execução com $THREADS threads: ${ELAPSED_TIME}ms"
    done
}

# Função para executar MPI com diferentes números de processos
run_mpi_tests() {
    echo "Executando testes para MPI..."
    for PROCS in $(seq 2 2 $((NUM_CORES * 2))); do
        if [ $PROCS -le $NUM_CORES ]; then
            # Executa em um único nó
            HOSTS="node1"
        else
            # Executa em múltiplos nós
            HOSTS=$NODES
        fi

        echo "Executando com $PROCS processos nos hosts: $HOSTS..."
        START_TIME=$(date +%s%N)  # Início do temporizador
        mpirun -np $PROCS --host $HOSTS $PROGRAM_MPI > "$OUTPUT_DIR/mpi_${PROCS}_procs.txt"
        END_TIME=$(date +%s%N)    # Fim do temporizador
        ELAPSED_TIME=$((($END_TIME - $START_TIME) / 1000000))  # Tempo em milissegundos
        echo "Tempo de execução com $PROCS processos: ${ELAPSED_TIME}ms"
    done
}

# Função principal
main() {
    # Executa os testes para OpenMP
    run_openmp_tests

    # Executa os testes para MPI
    run_mpi_tests

    echo "Testes concluídos. Resultados salvos em $OUTPUT_DIR."
}

# Executa a função principal
main
