import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Hand, Scissors, Scroll, RotateCcw, Trophy } from 'lucide-react';

const RockPaperScissors = ({ user }) => {
    const [gameState, setGameState] = useState('menu'); // menu, playing, result
    const [userChoice, setUserChoice] = useState(null);
    const [houseChoice, setHouseChoice] = useState(null);
    const [result, setResult] = useState(null);
    const [score, setScore] = useState({ player: 0, house: 0 });

    const choices = [
        { id: 'rock', icon: Hand, color: 'text-stone-400', label: 'Rock' },
        { id: 'paper', icon: Scroll, color: 'text-blue-200', label: 'Paper' },
        { id: 'scissors', icon: Scissors, color: 'text-red-400', label: 'Scissors' },
    ];

    const play = (choice) => {
        setUserChoice(choice);
        setGameState('playing');

        // Delay for "thinking" or animation
        setTimeout(() => {
            const house = choices[Math.floor(Math.random() * 3)];
            setHouseChoice(house);

            let res = '';
            if (choice.id === house.id) res = 'draw';
            else if (
                (choice.id === 'rock' && house.id === 'scissors') ||
                (choice.id === 'paper' && house.id === 'rock') ||
                (choice.id === 'scissors' && house.id === 'paper')
            ) {
                res = 'win';
                setScore(s => ({ ...s, player: s.player + 1 }));
            } else {
                res = 'lose';
                setScore(s => ({ ...s, house: s.house + 1 }));
            }
            setResult(res);
            setGameState('result');
        }, 1500);
    };

    const resetRound = () => {
        setUserChoice(null);
        setHouseChoice(null);
        setResult(null);
        setGameState('menu');
    };

    return (
        <div className="flex flex-col items-center justify-center p-4 h-full relative overflow-hidden">
            <h2 className="text-3xl font-black mb-1 p-2">Rock Paper Scissors</h2>
            <div className="flex gap-8 mb-8 text-xl font-mono bg-white/5 px-6 py-2 rounded-full border border-white/10">
                <div className="text-green-400">You: {score.player}</div>
                <div className="text-gray-500">vs</div>
                <div className="text-red-400">Bot: {score.house}</div>
            </div>

            <div className="h-48 w-full flex items-center justify-center mb-8 relative">
                <AnimatePresence mode="wait">
                    {gameState === 'menu' && (
                        <motion.div
                            initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.9 }}
                            className="flex gap-4 md:gap-8"
                        >
                            {choices.map(c => (
                                <button
                                    key={c.id}
                                    onClick={() => play(c)}
                                    className="flex flex-col items-center gap-2 group"
                                >
                                    <div className="w-24 h-24 md:w-32 md:h-32 bg-slate-800 rounded-2xl flex items-center justify-center shadow-lg border-b-4 border-slate-950 group-hover:-translate-y-2 group-hover:bg-slate-700 transition-all duration-300 group-active:translate-y-0 group-active:border-b-0">
                                        <c.icon size={48} className={c.color} />
                                    </div>
                                    <span className="font-bold text-gray-400 group-hover:text-white">{c.label}</span>
                                </button>
                            ))}
                        </motion.div>
                    )}

                    {gameState === 'playing' && (
                        <motion.div
                            initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
                            className="flex items-center gap-20"
                        >
                            <motion.div
                                animate={{ rotate: [0, -20, 0, -20, 0] }}
                                transition={{ duration: 0.5, repeat: Infinity }}
                            >
                                <Hand size={80} className="text-gray-500 -scale-x-100" />
                            </motion.div>
                            <div className="text-2xl font-bold animate-pulse">VS</div>
                            <motion.div
                                animate={{ rotate: [0, 20, 0, 20, 0] }}
                                transition={{ duration: 0.5, repeat: Infinity }}
                            >
                                <Hand size={80} className="text-gray-500" />
                            </motion.div>
                        </motion.div>
                    )}

                    {gameState === 'result' && userChoice && houseChoice && (
                        <motion.div
                            initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }}
                            className="flex flex-col items-center gap-6"
                        >
                            <div className="flex items-center gap-12">
                                <div className="text-center">
                                    <div className="w-24 h-24 bg-green-500/20 rounded-2xl flex items-center justify-center border-2 border-green-500 mb-2">
                                        <userChoice.icon size={48} className={userChoice.color} />
                                    </div>
                                    <p className="text-sm">You</p>
                                </div>

                                <div className="text-4xl font-black">
                                    {result === 'win' && <span className="text-green-500">WIN</span>}
                                    {result === 'lose' && <span className="text-red-500">LOSE</span>}
                                    {result === 'draw' && <span className="text-gray-400">DRAW</span>}
                                </div>

                                <div className="text-center">
                                    <div className={`w-24 h-24 rounded-2xl flex items-center justify-center border-2 mb-2 ${result === 'win' ? 'bg-red-500/20 border-red-500' : 'bg-slate-800 border-gray-600'}`}>
                                        <houseChoice.icon size={48} className={houseChoice.color} />
                                    </div>
                                    <p className="text-sm">Bot</p>
                                </div>
                            </div>

                            <button onClick={resetRound} className="btn-primary px-8 py-2 flex items-center gap-2 mt-4">
                                <RotateCcw size={18} /> Play Again
                            </button>
                        </motion.div>
                    )}
                </AnimatePresence>
            </div>
        </div>
    );
};

export default RockPaperScissors;
