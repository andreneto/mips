module Div(clk, reset, DivStart, dividendo, divisor, hi, lo, DivEnd, DivByZero);
	input clk, reset, DivStart;
	input[31:0] dividendo, divisor;
	
	output reg DivEnd, DivByZero;
	output reg[31:0] hi, lo;											// lo = quotient, hi = remainder

	reg[63:0] Resto;												// Resto = Resto - Divisor (book)
	reg[31:0] Divisor;

	reg dividendoSinal, divisorSinal, equalSinal;
	reg[4:0] counter;
	
	
	
	always@ (negedge clk or posedge reset) begin
		if(reset == 1) begin //...........................................................Reseta todo mundo para os valores default
			Resto <= 64'd0;
			Divisor <= 32'd0;
			lo <= 32'd0;
			hi <= 32'd0;
			counter <= 5'd0;
			dividendoSinal <= 0;
			divisorSinal <= 0;
			equalSinal <= 0;
			DivEnd <= 0;
			DivByZero <= 0;
		end
		else begin
			if(DivStart == 1)begin //.....................................................Inicia divisao
				if(counter == 5'd0) begin //..............................................Se o contador tiver zerado
					if(divisor == 32'd0) begin //.........................................Se o divisor for ZERO, para a divisao e da exceção
						DivByZero = 1;
						DivEnd = 1;
					end
					else begin //.........................................................Guarda o sinal de cada operando
						dividendoSinal = dividendo[31];
						divisorSinal = divisor[31];
						
						Resto[63:32] = 32'd0;
						Resto[31:0] = (dividendoSinal == 1)? -dividendo : dividendo;//....Se dividendo for negativo, inverte 
						
						Divisor[31:0] = (divisorSinal == 1)? -divisor : divisor;//........Mesma coisa pro divisor
						
						Resto = Resto << 1;//.............................................Desloca o resto antes de iniciar
						
						DivByZero = 0;//..................................................Por via das duvidas, seta flag de div/0 como 0
						DivEnd = 0;//.....................................................Ta so comecando
					
					end
				end
				
				/*********************************************ALGORITMO DO LIVRO PAG 139-141**************************************************************************/
				Resto[63:32] = Resto[63:32] - Divisor;//..................................Subtrai o divisor do resto 
				if(Resto[63] == 1)begin
					Resto[63:32] = Resto[63:32] + Divisor;//..............................Se o resto ficar negativo, soma pra voltar como tava
					Resto = Resto << 1;//.................................................Desloca o resto(Q) pra direita e o LSB é setado como ZERO, mas nao precisa, ja q o deslocamento ja faz isso
					
				end
				else begin
					Resto = Resto << 1;//.................................................Se o resto for positivo, desloca o resto(Q) pra direita e
					Resto[0] = 1;//.......................................................Seta o LSB pra 1
				
				end
				Divisor = Divisor >> 1;//...........................................................Depois desloca o divisor pra esq pra ele acompanhar o dividendo
				
				if(counter == 5'd31) begin//..............................................Se o contador for maior que 32, quer dizer que ja realizou todas operacoes
					Resto [63:32] = Resto [63:32] >> 1;//.................................Desloca o resto pra arrumar
					DivEnd = 1;//.........................................................Flag do fim de divisao
					 equalSinal = dividendoSinal ~^ divisorSinal;//.......................XNOR pra arrumar os sinais
					 
					if(equalSinal == 0)
						Resto[31:0] = -Resto[31:0];//.....................................Se for =0 precisa arrumar o sinal
					if(Resto[63:32] != 32'd0)
						if(equalSinal == 1)
							Resto [63:32] = -Resto[63:32];//..............................Mesma coisa pro quociente
					lo = Resto[31:0];//...................................................Manda Quociente pro MFLO
					hi = Resto[63:32];//..................................................Manda Resto pro MFHI
					
					counter = 5'd0;//.....................................................Zera o contador
				
				end
				
				counter = counter + 5'd1;//............................Incrementa o contador
					
			end
		end
	end
endmodule
	
