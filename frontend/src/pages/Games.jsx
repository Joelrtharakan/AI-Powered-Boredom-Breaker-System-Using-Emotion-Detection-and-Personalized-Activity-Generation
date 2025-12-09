import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Play, RotateCcw, Zap, Hash, Copy } from 'lucide-react';

export default function Games() {
    const [activeGame, setActiveGame] = useState(null);

    return (
        <div className="min-h-screen pt-20 pb-10 px-4 max-w-7xl mx-auto">
            <div className="mb-12 text-center">
                <h1 className="text-5xl font-black title-gradient mb-4">Arcade Zone</h1>
                <p className="text-gray-400">Boost your dopamine with these quick neural activators.</p>
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
                        />
                        <GameCard
                            title="Number Guess"
                            desc="Find the hidden number between 1-100."
                            icon={Hash}
                            color="from-cyan-500 to-blue-500"
                            onClick={() => setActiveGame('number')}
                        />
                        <GameCard
                            title="Memory Flip"
                            desc="Match the pairs before time runs out."
                            icon={Copy}
                            color="from-purple-500 to-pink-500"
                            onClick={() => setActiveGame('memory')}
                        />
                    </motion.div>
                ) : (
                    <motion.div
                        initial={{ opacity: 0, y: 50 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: 50 }}
                        className="max-w-4xl mx-auto"
                    >
                        <button
                            onClick={() => setActiveGame(null)}
                            className="mb-8 text-gray-400 hover:text-white flex items-center gap-2 transition-colors"
                        >
                            ← Back to Arcade
                        </button>

                        <div className="glass-card p-1 min-h-[500px] flex flex-col relative overflow-hidden">
                            {activeGame === 'reaction' && <ReactionGame />}
                            {activeGame === 'number' && <NumberGuessGame />}
                            {activeGame === 'memory' && <MemoryGame />}
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    )
}

const GameCard = ({ title, desc, icon: Icon, color, onClick }) => (
    <motion.div
        whileHover={{ scale: 1.05, translateY: -5 }}
        whileTap={{ scale: 0.95 }}
        onClick={onClick}
        className="glass-card p-8 flex flex-col items-center text-center gap-6 cursor-pointer group hover:bg-white/10"
    >
        <div className={`w-20 h-20 rounded-3xl bg-gradient-to-tr ${color} flex items-center justify-center shadow-lg group-hover:shadow-[0_0_30px_rgba(255,255,255,0.3)] transition-all`}>
            <Icon size={32} className="text-white" />
        </div>
        <div>
            <h3 className="text-2xl font-bold mb-2">{title}</h3>
            <p className="text-gray-400 text-sm leading-relaxed">{desc}</p>
        </div>
        <div className="mt-auto pt-4">
            <span className="text-primary-light font-bold text-sm tracking-wider uppercase group-hover:text-white transition-colors">Play Now</span>
        </div>
    </motion.div>
);

// --- Game Components ---

const ReactionGame = () => {
    const [state, setState] = useState('waiting'); // waiting, ready, now, result
    const [startTime, setStartTime] = useState(0);
    const [score, setScore] = useState(0);

    const start = () => {
        setState('ready');
        setTimeout(() => {
            setState('now');
            setStartTime(Date.now());
        }, 1000 + Math.random() * 3000);
    };

    const handleClick = () => {
        if (state === 'now') {
            setScore(Date.now() - startTime);
            setState('result');
        } else if (state === 'ready') {
            setState('waiting');
            alert("Too early!");
        }
    };

    return (
        <div
            className={`flex-1 flex flex-col items-center justify-center cursor-pointer transition-colors duration-200 ${state === 'now' ? 'bg-green-500' : state === 'result' ? 'bg-transparent' : 'bg-transparent'
                }`}
            onMouseDown={handleClick}
        >
            {state === 'waiting' && (
                <div className="text-center">
                    <Zap size={64} className="mx-auto mb-4 text-gray-500" />
                    <h2 className="text-3xl font-bold mb-4">Reaction Time</h2>
                    <p className="mb-8 text-gray-400">When the screen turns green, click as fast as you can.</p>
                    <button onClick={(e) => { e.stopPropagation(); start(); }} className="btn-primary">Start Game</button>
                </div>
            )}
            {state === 'ready' && <h2 className="text-4xl font-bold text-red-500">Wait for Green...</h2>}
            {state === 'now' && <h2 className="text-6xl font-black text-white">CLICK!</h2>}
            {state === 'result' && (
                <div className="text-center">
                    <h2 className="text-2xl text-gray-300 mb-2">Your Time</h2>
                    <h1 className="text-6xl font-black text-white mb-8">{score} ms</h1>
                    <button onClick={(e) => { e.stopPropagation(); start(); }} className="btn-primary flex items-center gap-2 mx-auto">
                        <RotateCcw size={18} /> Try Again
                    </button>
                </div>
            )}
        </div>
    );
};

const NumberGuessGame = () => {
    const [target, setTarget] = useState(Math.floor(Math.random() * 100) + 1);
    const [guess, setGuess] = useState('');
    const [message, setMessage] = useState('Guess a number between 1 and 100');
    const [history, setHistory] = useState([]);

    const handleGuess = (e) => {
        e.preventDefault();
        const num = parseInt(guess);
        if (!num) return;

        let msg = '';
        if (num === target) msg = '🎉 Correct! You won!';
        else if (num < target) msg = 'Too Low 📉';
        else msg = 'Too High 📈';

        setHistory([num, ...history]);
        setMessage(msg);
        setGuess('');
    };

    const reset = () => {
        setTarget(Math.floor(Math.random() * 100) + 1);
        setHistory([]);
        setMessage('Guess a number between 1 and 100');
    }

    return (
        <div className="flex-1 flex flex-col items-center justify-center p-8">
            <h2 className="text-3xl font-bold mb-4">Number Guessing</h2>
            <div className="bg-white/5 p-4 rounded-xl mb-8 w-full max-w-sm text-center">
                <p className="text-xl text-primary-light font-medium">{message}</p>
            </div>

            <form onSubmit={handleGuess} className="flex gap-4 w-full max-w-xs mb-8">
                <input
                    type="number"
                    className="input-field text-center text-2xl font-bold"
                    value={guess}
                    onChange={e => setGuess(e.target.value)}
                    autoFocus
                />
                <button type="submit" className="btn-primary px-6">Go</button>
            </form>

            {history.length > 0 && (
                <div className="flex gap-2 justify-center flex-wrap">
                    {history.map((h, i) => (
                        <span key={i} className="px-3 py-1 bg-white/5 rounded-full text-sm text-gray-400">{h}</span>
                    ))}
                </div>
            )}
            <button onClick={reset} className="mt-8 text-sm text-gray-500 hover:text-white">Reset Game</button>
        </div>
    );
};

const MemoryGame = () => {
    // Simple 4x3 grid
    const emojis = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊'];
    const [cards, setCards] = useState([]);
    const [flipped, setFlipped] = useState([]);
    const [solved, setSolved] = useState([]);

    useEffect(() => {
        const deck = [...emojis, ...emojis].sort(() => Math.random() - 0.5);
        setCards(deck.map((emoji, id) => ({ id, emoji })));
    }, []);

    const handleCardClick = (id) => {
        if (flipped.length === 2 || flipped.includes(id) || solved.includes(id)) return;
        const newFlipped = [...flipped, id];
        setFlipped(newFlipped);

        if (newFlipped.length === 2) {
            const [first, second] = newFlipped;
            if (cards[first].emoji === cards[second].emoji) {
                setSolved([...solved, first, second]);
                setFlipped([]);
            } else {
                setTimeout(() => setFlipped([]), 1000);
            }
        }
    };

    return (
        <div className="flex-1 flex flex-col items-center justify-center p-8">
            <h2 className="text-3xl font-bold mb-8">Memory Flip</h2>
            <div className="grid grid-cols-4 gap-4">
                {cards.map((card, i) => (
                    <motion.div
                        key={i}
                        className={`w-16 h-16 md:w-20 md:h-20 rounded-xl cursor-pointer flex items-center justify-center text-3xl transition-all duration-300 ${flipped.includes(i) || solved.includes(i) ? 'bg-white text-black rotate-y-180' : 'bg-primary-dark/50 hover:bg-primary-dark border border-white/10'
                            }`}
                        onClick={() => handleCardClick(i)}
                        whileHover={{ scale: 1.05 }}
                    >
                        {(flipped.includes(i) || solved.includes(i)) ? card.emoji : '?'}
                    </motion.div>
                ))}
            </div>
            {solved.length === cards.length && cards.length > 0 && (
                <div className="mt-8">
                    <h3 className="text-2xl font-bold text-green-400 mb-2">You Won!</h3>
                    <button onClick={() => window.location.reload()} className="btn-primary">Play Again</button>
                </div>
            )}
        </div>
    );
}
