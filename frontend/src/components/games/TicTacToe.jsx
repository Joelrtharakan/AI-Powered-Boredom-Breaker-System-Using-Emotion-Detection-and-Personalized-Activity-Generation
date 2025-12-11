import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { RotateCcw, X, Circle } from 'lucide-react';

const TicTacToe = ({ onBack }) => {
    const [board, setBoard] = useState(Array(9).fill(null));
    const [isPlayerTurn, setIsPlayerTurn] = useState(true);
    const [winner, setWinner] = useState(null); // 'X', 'O', 'Draw', or null

    const checkWinner = (squares) => {
        const lines = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6]
        ];
        for (let i = 0; i < lines.length; i++) {
            const [a, b, c] = lines[i];
            if (squares[a] && squares[a] === squares[b] && squares[a] === squares[c]) {
                return squares[a];
            }
        }
        return squares.includes(null) ? null : 'Draw';
    };

    const handleClick = (i) => {
        if (board[i] || winner || !isPlayerTurn) return;

        const newBoard = [...board];
        newBoard[i] = 'X';
        setBoard(newBoard);

        const result = checkWinner(newBoard);
        if (result) {
            setWinner(result);
        } else {
            setIsPlayerTurn(false);
        }
    };

    // Minimax Algorithm
    const minimax = (currentBoard, depth, isMaximizing) => {
        const result = checkWinner(currentBoard);
        if (result === 'O') return 10 - depth;
        if (result === 'X') return depth - 10;
        if (result === 'Draw') return 0;

        if (isMaximizing) {
            let bestScore = -Infinity;
            for (let i = 0; i < 9; i++) {
                if (!currentBoard[i]) {
                    currentBoard[i] = 'O';
                    const score = minimax(currentBoard, depth + 1, false);
                    currentBoard[i] = null;
                    bestScore = Math.max(score, bestScore);
                }
            }
            return bestScore;
        } else {
            let bestScore = Infinity;
            for (let i = 0; i < 9; i++) {
                if (!currentBoard[i]) {
                    currentBoard[i] = 'X';
                    const score = minimax(currentBoard, depth + 1, true);
                    currentBoard[i] = null;
                    bestScore = Math.min(score, bestScore);
                }
            }
            return bestScore;
        }
    };

    // AI Turn
    useEffect(() => {
        if (!isPlayerTurn && !winner) {
            const timer = setTimeout(() => {
                const available = board.map((val, idx) => val === null ? idx : null).filter(val => val !== null);

                if (available.length > 0) {
                    let bestScore = -Infinity;
                    let move;

                    // Optimization: If first move, take center or corner to save computing
                    if (available.length >= 8 && !board[4]) move = 4;
                    else {
                        for (let i = 0; i < 9; i++) {
                            if (!board[i]) {
                                const newBoard = [...board];
                                newBoard[i] = 'O';
                                const score = minimax(newBoard, 0, false);
                                if (score > bestScore) {
                                    bestScore = score;
                                    move = i;
                                }
                            }
                        }
                    }

                    // Fallback to random if something fails (shouldn't happen)
                    if (move === undefined) move = available[Math.floor(Math.random() * available.length)];

                    const newBoard = [...board];
                    newBoard[move] = 'O';
                    setBoard(newBoard);

                    const result = checkWinner(newBoard);
                    if (result) setWinner(result);
                    else setIsPlayerTurn(true);
                }
            }, 600); // Slight delay for realism
            return () => clearTimeout(timer);
        }
    }, [isPlayerTurn, winner, board]);

    const resetGame = () => {
        setBoard(Array(9).fill(null));
        setWinner(null);
        setIsPlayerTurn(true);
    };

    return (
        <div className="flex flex-col items-center justify-center p-4 h-full">
            <h2 className="text-4xl font-black mb-2 text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-purple-400">Tic-Tac-Toe</h2>
            <p className="text-gray-400 mb-8">Can you beat the AI?</p>

            <div className="relative mb-8 w-full max-w-[350px]">
                <div className="grid grid-cols-3 gap-3 bg-slate-800 p-3 rounded-2xl shadow-2xl aspect-square">
                    {board.map((cell, i) => (
                        <motion.button
                            key={i}
                            whileHover={!cell && !winner ? { scale: 0.95 } : {}}
                            whileTap={!cell && !winner ? { scale: 0.9 } : {}}
                            onClick={() => handleClick(i)}
                            className={`w-full h-full bg-slate-700 rounded-xl flex items-center justify-center text-5xl font-bold shadow-inner transition-colors ${!cell && !winner ? 'hover:bg-slate-600 cursor-pointer' : 'cursor-default'
                                }`}
                        >
                            {cell === 'X' && <X size="50%" className="text-blue-400" />}
                            {cell === 'O' && <Circle size="45%" className="text-purple-400" />}
                        </motion.button>
                    ))}
                </div>

                {winner && (
                    <motion.div
                        initial={{ opacity: 0, scale: 0.5 }}
                        animate={{ opacity: 1, scale: 1 }}
                        className="absolute inset-0 flex items-center justify-center bg-black/80 rounded-xl"
                    >
                        <div className="text-center p-4">
                            <h3 className={`text-4xl font-black mb-2 ${winner === 'X' ? 'text-blue-400' : winner === 'O' ? 'text-purple-400' : 'text-gray-300'}`}>
                                {winner === 'X' ? 'You Win!' : winner === 'O' ? 'AI Wins!' : 'Draw!'}
                            </h3>
                            <button onClick={resetGame} className="btn-primary flex items-center gap-2 mx-auto mt-4 px-6 py-2 text-sm">
                                <RotateCcw size={16} /> Play Again
                            </button>
                        </div>
                    </motion.div>
                )}
            </div>

            {!winner && (
                <div className="text-sm font-mono text-gray-400 bg-white/5 px-4 py-2 rounded-full">
                    {isPlayerTurn ? "Your Turn (X)" : "AI Thinking... (O)"}
                </div>
            )}
        </div>
    );
};

export default TicTacToe;
