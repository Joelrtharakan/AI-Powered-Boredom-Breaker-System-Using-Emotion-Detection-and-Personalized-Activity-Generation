import { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Play, RotateCcw, Zap, Hash, Copy, Trophy, ArrowLeft, Brain } from 'lucide-react';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api/v1';

export default function Games() {
    const { user } = useAuth();
    const [activeGame, setActiveGame] = useState(null);

    return (
        <div className="min-h-screen pt-20 pb-4 px-4 max-w-7xl mx-auto font-sans">
            {/* Header */}
            <div className="mb-10 text-center">
                <motion.div
                    initial={{ y: -20, opacity: 0 }} animate={{ y: 0, opacity: 1 }}
                    className="flex items-center justify-center gap-4 mb-2"
                >
                    <h1 className="text-4xl font-black text-transparent bg-clip-text bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 drop-shadow-xl">
                        Arcade Zone
                    </h1>
                </motion.div>
                <motion.p
                    initial={{ opacity: 0 }} animate={{ opacity: 1 }} delay={0.2}
                    className="text-gray-400 text-sm max-w-xl mx-auto"
                >
                    Boost your dopamine with these quick neural activators. Win to earn points!
                </motion.p>
            </div>

            <AnimatePresence mode="wait">
                {!activeGame ? (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="grid md:grid-cols-3 gap-8"
                    >
                        <GameCard
                            title="Reaction Time"
                            desc="Test your visual reflexes. Click when green."
                            icon={Zap}
                            color="from-rose-500 to-orange-500"
                            onClick={() => setActiveGame('reaction')}
                            delay={0.1}
                        />
                        <GameCard
                            title="Number Guess"
                            desc="Find the hidden number between 1-100."
                            icon={Hash}
                            color="from-cyan-500 to-blue-500"
                            onClick={() => setActiveGame('number')}
                            delay={0.2}
                        />
                        <GameCard
                            title="Memory Flip"
                            desc="Match the pairs before time runs out."
                            icon={Copy}
                            color="from-purple-500 to-pink-500"
                            onClick={() => setActiveGame('memory')}
                            delay={0.3}
                        />
                    </motion.div>
                ) : (
                    <motion.div
                        initial={{ opacity: 0, scale: 0.95 }}
                        animate={{ opacity: 1, scale: 1 }}
                        exit={{ opacity: 0, scale: 0.95 }}
                        className="max-w-4xl mx-auto"
                    >
                        <button
                            onClick={() => setActiveGame(null)}
                            className="mb-8 text-white/50 hover:text-white flex items-center gap-2 transition-colors group px-4 py-2 rounded-full hover:bg-white/10 w-fit"
                        >
                            <ArrowLeft size={20} className="group-hover:-translate-x-1 transition-transform" />
                            Back to Arcade
                        </button>

                        <div className="glass-card min-h-[500px] flex flex-col relative overflow-hidden rounded-3xl border border-white/10 shadow-2xl bg-black/40 backdrop-blur-xl">
                            {activeGame === 'reaction' && <ReactionGame user={user} />}
                            {activeGame === 'number' && <NumberGuessGame user={user} />}
                            {activeGame === 'memory' && <MemoryGame user={user} />}
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    )
}

const GameCard = ({ title, desc, icon: Icon, color, onClick, delay }) => (
    <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay }}
        whileHover={{ scale: 1.03, y: -5 }}
        whileTap={{ scale: 0.97 }}
        onClick={onClick}
        className="glass-card p-1 cursor-pointer group hover:shadow-2xl hover:shadow-primary/20 transition-all duration-300 rounded-3xl"
    >
        <div className="bg-[#1e293b]/80 p-8 h-full rounded-[20px] flex flex-col items-center text-center gap-6 border border-white/5 group-hover:border-white/20 transition-colors">
            <div className={`w-20 h-20 rounded-2xl bg-gradient-to-tr ${color} flex items-center justify-center shadow-lg group-hover:shadow-[0_0_40px_rgba(255,255,255,0.2)] transition-all duration-500 group-hover:rotate-12`}>
                <Icon size={32} className="text-white drop-shadow-md" />
            </div>
            <div>
                <h3 className="text-2xl font-bold mb-2 text-white group-hover:text-primary-light transition-colors">{title}</h3>
                <p className="text-gray-400 text-sm leading-relaxed">{desc}</p>
            </div>
            <div className="mt-auto pt-4 w-full">
                <div className="w-full py-2 rounded-lg bg-white/5 group-hover:bg-white/10 text-primary-light font-bold text-xs tracking-widest uppercase transition-colors">
                    Play Now
                </div>
            </div>
        </div>
    </motion.div>
);

// --- Game Components ---

const ReactionGame = ({ user }) => {
    const [state, setState] = useState('waiting');
    const [score, setScore] = useState(0);
    const timeoutRef = useRef(null);
    const startTimeRef = useRef(0);

    useEffect(() => {
        return () => { if (timeoutRef.current) clearTimeout(timeoutRef.current); };
    }, []);

    const start = () => {
        setState('waiting');
        const delay = Math.random() * 2000 + 1000;
        timeoutRef.current = setTimeout(() => {
            setState('now');
            startTimeRef.current = Date.now();
        }, delay);

        if (user) axios.post(`${API_URL}/games/reaction/start`, { user_id: user.id, difficulty: 'normal' }).catch(() => { });
    };

    const handleClick = () => {
        if (state === 'now') {
            const time = Date.now() - startTimeRef.current;
            setScore(time);
            setState('result');
            if (user) {
                axios.post(`${API_URL}/games/reaction/submit`, {
                    user_id: user.id,
                    result: { score: time }
                }).catch(e => console.error(e));
            }
        } else if (state === 'waiting' && timeoutRef.current) {
            // Clicked too early logic would go here if needed
            // Current waiting UI covers click area with non-clickable if needed, or handle here
        }
    };

    // Using onMouseDown on the container for instant reaction
    const containerClick = () => {
        if (state === 'now') handleClick();
        else if (state === 'waiting' && timeoutRef.current) {
            // Too early
            clearTimeout(timeoutRef.current);
            alert("Too early! Wait for GREEN.");
            setState('waiting'); // Reset state without automatic start or ask to click start again
            // Actually better to just force restart manually
            timeoutRef.current = null;
        }
    };

    return (
        <div
            className={`flex-1 flex flex-col items-center justify-center cursor-pointer transition-all duration-300 relative select-none ${state === 'now' ? 'bg-emerald-500' : state === 'result' ? 'bg-transparent' : 'bg-transparent'
                }`}
            onMouseDown={state !== 'result' ? containerClick : undefined}
        >
            {state === 'waiting' && !timeoutRef.current && (
                /* Initial Start State */
                <div className="text-center z-10">
                    <Zap size={80} className="mx-auto mb-6 text-yellow-500 drop-shadow-glow animate-pulse" />
                    <h2 className="text-4xl font-black mb-4 tracking-tight">Reaction Time</h2>
                    <p className="mb-8 text-gray-400 text-lg max-w-md mx-auto">Click <span className="text-emerald-400 font-bold">Start Game</span>, then click anywhere when the screen turns GREEN.</p>
                    <button onClick={(e) => { e.stopPropagation(); start(); }} className="btn-primary px-10 py-4 text-lg shadow-lg shadow-primary/30 hover:scale-105 transition-transform">
                        Start Game
                    </button>
                </div>
            )}

            {state === 'waiting' && timeoutRef.current && (
                /* Actually waiting for green */
                <div className="text-center z-10 pointer-events-none">
                    <h2 className="text-5xl font-bold text-red-500 tracking-widest animate-pulse">WAIT...</h2>
                </div>
            )}

            {state === 'now' && (
                <div className="text-center animate-bounce pointer-events-none">
                    <h2 className="text-8xl font-black text-white drop-shadow-xl">CLICK!</h2>
                </div>
            )}
            {state === 'result' && (
                <div className="text-center z-10 cursor-default">
                    <h2 className="text-3xl text-gray-400 mb-2 font-light">Reaction Time</h2>
                    <h1 className="text-9xl font-black text-transparent bg-clip-text bg-gradient-to-b from-white to-gray-400 mb-6">{score} <span className="text-4xl text-gray-600">ms</span></h1>
                    <div className="bg-white/5 inline-block px-6 py-2 rounded-full mb-8 text-gray-400">
                        {score < 200 ? "Godlike ⚡" : score < 300 ? "Great 🏎️" : "Average 🐢"}
                    </div>
                    <div>
                        <button onClick={(e) => { e.stopPropagation(); start(); }} className="btn-primary flex items-center gap-2 mx-auto px-8 py-3">
                            <RotateCcw size={20} /> Try Again
                        </button>
                    </div>
                </div>
            )}
        </div>
    );
};

const NumberGuessGame = ({ user }) => {
    const [target, setTarget] = useState(Math.floor(Math.random() * 100) + 1);
    const [guess, setGuess] = useState('');
    const [message, setMessage] = useState('Guess a number between 1 and 100');
    const [status, setStatus] = useState('neutral'); // neutral, low, high, win
    const [history, setHistory] = useState([]);

    const handleGuess = (e) => {
        e.preventDefault();
        const num = parseInt(guess);
        if (!num) return;

        let msg = '';
        let st = 'neutral';

        if (num === target) {
            msg = '🎉 Correct! You won!';
            st = 'win';
            if (user) {
                axios.post(`${API_URL}/games/number_guess/submit`, {
                    user_id: user.id,
                    result: { score: 100 - history.length * 5, attempts: history.length + 1 }
                }).catch(e => console.error(e));
            }
        }
        else if (num < target) { msg = 'Too Low 📉 try higher'; st = 'low'; }
        else { msg = 'Too High 📈 try lower'; st = 'high'; }

        setHistory([num, ...history]);
        setMessage(msg);
        setStatus(st);
        setGuess('');
    };

    const reset = () => {
        setTarget(Math.floor(Math.random() * 100) + 1);
        setHistory([]);
        setMessage('Guess a number between 1 and 100');
        setStatus('neutral');
    }

    return (
        <div className="flex-1 flex flex-col items-center justify-center p-8 bg-gradient-to-br from-blue-900/20 to-purple-900/20">
            <h2 className="text-4xl font-black mb-8">Number Guess</h2>

            <motion.div
                key={message}
                initial={{ scale: 0.9, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}
                className={`p-6 rounded-2xl mb-8 w-full max-w-sm text-center border transition-colors ${status === 'win' ? 'bg-green-500/20 border-green-500 text-green-200' :
                    status === 'low' ? 'bg-blue-500/20 border-blue-500 text-blue-200' :
                        status === 'high' ? 'bg-orange-500/20 border-orange-500 text-orange-200' :
                            'bg-white/5 border-white/10 text-gray-300'
                    }`}
            >
                <p className="text-xl font-bold">{message}</p>
            </motion.div>

            {status !== 'win' ? (
                <form onSubmit={handleGuess} className="flex gap-4 w-full max-w-xs mb-8">
                    <input
                        type="number"
                        className="w-full bg-black/40 border-2 border-white/10 rounded-xl px-4 text-center text-3xl font-bold py-3 focus:outline-none focus:border-primary transition-colors"
                        value={guess}
                        onChange={e => setGuess(e.target.value)}
                        autoFocus
                        placeholder="#"
                    />
                    <button type="submit" className="btn-primary px-6 rounded-xl text-lg">Go</button>
                </form>
            ) : (
                <button onClick={reset} className="btn-primary px-8 py-3 rounded-xl text-lg mb-8 animate-bounce">Play Again</button>
            )}

            {history.length > 0 && (
                <div className="flex flex-col items-center">
                    <span className="text-xs uppercase tracking-widest text-gray-500 mb-2">History</span>
                    <div className="flex gap-2 justify-center flex-wrap max-w-md">
                        {history.map((h, i) => (
                            <motion.span
                                key={i} layout initial={{ scale: 0 }} animate={{ scale: 1 }}
                                className="px-3 py-1 bg-white/5 border border-white/5 rounded-full text-sm text-gray-400 font-mono"
                            >
                                {h}
                            </motion.span>
                        ))}
                    </div>
                </div>
            )}
        </div>
    );
};

const MemoryGame = ({ user }) => {
    const emojis = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼']; // 8 pairs, 16 cards (4x4)
    const [cards, setCards] = useState([]);
    const [flipped, setFlipped] = useState([]);
    const [solved, setSolved] = useState([]);
    const [attempts, setAttempts] = useState(0);

    const initializeGame = () => {
        const deck = [...emojis, ...emojis].sort(() => Math.random() - 0.5);
        setCards(deck.map((emoji, id) => ({ id, emoji })));
        setFlipped([]);
        setSolved([]);
        setAttempts(0);
    };

    useEffect(() => {
        initializeGame();
    }, []);

    const handleCardClick = (id) => {
        if (flipped.length === 2 || flipped.includes(id) || solved.includes(id)) return;

        const newFlipped = [...flipped, id];
        setFlipped(newFlipped);

        if (newFlipped.length === 2) {
            setAttempts(a => a + 1);
            const [first, second] = newFlipped;
            if (cards[first].emoji === cards[second].emoji) {
                const newSolved = [...solved, first, second];
                setSolved(newSolved);
                setFlipped([]);

                if (newSolved.length === cards.length && user) {
                    axios.post(`${API_URL}/games/memory/submit`, {
                        user_id: user.id,
                        result: { score: 1000 - attempts * 10 }
                    }).catch(e => console.error(e));
                }
            } else {
                setTimeout(() => setFlipped([]), 1000);
            }
        }
    };

    return (
        <div className="flex-1 flex flex-col items-center justify-center p-8">
            <div className="flex items-center justify-between w-full max-w-lg mb-8">
                <h2 className="text-4xl font-black">Memory Flip</h2>
                <div className="bg-white/10 px-4 py-2 rounded-full font-mono text-primary-light">
                    Moves: {attempts}
                </div>
            </div>

            <div className="grid grid-cols-4 gap-3 md:gap-4">
                {cards.map((card, i) => (
                    <motion.div
                        key={i}
                        className={`w-16 h-16 md:w-20 md:h-20 rounded-xl cursor-pointer flex items-center justify-center text-3xl transition-all duration-300 relative transform-style-3d ${flipped.includes(i) || solved.includes(i) ? 'rotate-y-180' : ''
                            }`}
                        onClick={() => handleCardClick(i)}
                        whileHover={{ scale: 1.05 }}
                    >
                        {/* Front (Hidden) */}
                        <div className={`absolute inset-0 bg-gradient-to-br from-indigo-600 to-purple-600 rounded-xl border-b-4 border-indigo-900/50 flex items-center justify-center backface-hidden ${flipped.includes(i) || solved.includes(i) ? 'opacity-0' : 'opacity-100'}`}>
                            <Brain size={24} className="text-white/20" />
                        </div>

                        {/* Back (Symbol) */}
                        <div className={`absolute inset-0 bg-white rounded-xl flex items-center justify-center backface-hidden border-b-4 border-gray-300 ${flipped.includes(i) || solved.includes(i) ? 'opacity-100' : 'opacity-0'}`}>
                            <span className="text-4xl">{card.emoji}</span>
                        </div>
                    </motion.div>
                ))}
            </div>

            {solved.length === cards.length && cards.length > 0 && (
                <motion.div
                    initial={{ scale: 0.5, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}
                    className="mt-8 text-center bg-black/50 p-6 rounded-2xl backdrop-blur-md border border-green-500/50"
                >
                    <Trophy size={48} className="mx-auto text-yellow-400 mb-2 drop-shadow-glow" />
                    <h3 className="text-2xl font-bold text-white mb-2">Victory!</h3>
                    <p className="text-gray-400 mb-4">You solved it in {attempts} moves.</p>
                    <button onClick={initializeGame} className="btn-primary w-full">Play Again</button>
                </motion.div>
            )}
        </div>
    );
}
