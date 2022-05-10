/* reduce matrix A to upper triangular form */ 
void eliminate (double **A, int N, int B) { 
    int i, j, k, I, J; 
    /* size of block is (M*M) */ 
    int M = N/B;        
        /* for all block rows */ 
        for (I = 0; I < B; I++) {   
            /* for all block columns */ 
            for (J = 0; J < B; J++) {       
            /* loop over pivot elements */ 
                for (k = 0; k <= Min((I + 1)* M - 1, (J + 1) * M - 1); k++) {          
                    /* if pivot element within block */ 
                    if (k >= I*M && k <= (I + 1) * M - 1) {   
                        /* perform calculations on pivot */ 
                        for (j = Max(k + 1, J * M); j <= (J + 1) * M - 1; j++) { 
                            A[k][j] = A[k][j] / A[k][k];   
                        } 
                        /* if last element in row */ 
                        if (j == N) A[k][k] = 1.0;   
                    } 
                    /* for all rows below pivot row within block */ 
                    for (i = Max(k + 1, I * M); i <= (I + 1) * M - 1; i++) {            
                        /* for all elements in row within block */ 
                        for (j = Max(k + 1, J * M); j <= (J + 1) * M - 1; j++) { 
                            A[i][j] = A[i][j] - A[i][k] * A[k][j];   
                        }        
                    /* if last element in row */ 
                    if (j == N) A[i][k] = 0.0;    
                } 
            } 
        } 
    } 
}    /* end eliminate */ 