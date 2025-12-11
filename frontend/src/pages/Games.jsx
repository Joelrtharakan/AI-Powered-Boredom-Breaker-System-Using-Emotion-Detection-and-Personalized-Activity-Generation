import { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Play, RotateCcw, Zap, Hash, Copy, Trophy, ArrowLeft, Brain, Target, Grip, LayoutGrid, X, Hand, Move, Gamepad2, Ghost } from 'lucide-react';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';
import TicTacToe from '../components/games/TicTacToe';
import RockPaperScissors from '../components/games/RockPaperScissors';
import SnakeGame from '../components/games/SnakeGame';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api/v1';

export default function Games() {
    const { user } = useAuth();
    const [activeGame, setActiveGame] = useState(null);
    const [highScores, setHighScores] = useState({});

    const fetchScores = async () => {
        if (!user) return;
        try {
            const res = await axios.get(`${API_URL}/games/scores/${user.id}`);
            setHighScores(res.data);
        } catch (e) {
            console.error("Failed to fetch scores", e);
        }
    };

    useEffect(() => {
        fetchScores();
    }, [user, activeGame]);

    return (
        <div className="h-screen pt-20 pb-0 px-6 max-w-7xl mx-auto font-sans flex flex-col overflow-hidden">
            {/* Header */}
            <div className="mb-8 text-center shrink-0">
                <motion.div
                    initial={{ y: -20, opacity: 0 }} animate={{ y: 0, opacity: 1 }}
                    className="flex items-center justify-center gap-4 mb-3"
                >
                    <h1 className="text-5xl font-black text-transparent bg-clip-text bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 drop-shadow-xl">
                        Arcade Zone
                    </h1>
                </motion.div>
                <motion.p
                    initial={{ opacity: 0 }} animate={{ opacity: 1 }} delay={0.2}
                    className="text-gray-400 text-lg max-w-xl mx-auto"
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
                        className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8 flex-1 overflow-y-auto p-4 content-start pb-24 scrollbar-hide"
                    >
                        <GameCard
                            title="Reaction Time"
                            desc="Test your visual reflexes. Click when green."
                            icon={Zap}
                            color="from-rose-500 to-orange-500"
                            onClick={() => setActiveGame('reaction')}
                            score={highScores['reaction'] ? `${highScores['reaction']}ms` : null}
                            delay={0.1}
                        />
                        <GameCard
                            title="Aim Trainer"
                            desc="Click targets as fast as you can! (30s)"
                            icon={Target}
                            color="from-red-500 to-rose-600"
                            onClick={() => setActiveGame('aim')}
                            score={highScores['aim'] ? `${highScores['aim']} pts` : null}
                            delay={0.15}
                        />
                        <GameCard
                            title="Number Guess"
                            desc="Find the hidden number using logic."
                            icon={Hash}
                            color="from-cyan-500 to-blue-500"
                            onClick={() => setActiveGame('number')}
                            score={highScores['number_guess'] ? `${highScores['number_guess']} pts` : null}
                            delay={0.2}
                        />
                        <GameCard
                            title="Chimp Test"
                            desc="Are you smarter than a chimp?"
                            icon={Grip}
                            color="from-yellow-500 to-orange-500"
                            onClick={() => setActiveGame('chimp')}
                            score={highScores['chimp'] ? `Lvl ${highScores['chimp']}` : null}
                            delay={0.25}
                        />
                        <GameCard
                            title="Memory Flip"
                            desc="Match the pairs before time runs out."
                            icon={Copy}
                            color="from-purple-500 to-pink-500"
                            onClick={() => setActiveGame('memory')}
                            score={highScores['memory'] ? `${highScores['memory']} pts` : null}
                            delay={0.3}
                        />
                        <GameCard
                            title="Visual Memory"
                            desc="Memorize the pattern of tiles."
                            icon={LayoutGrid}
                            color="from-indigo-500 to-violet-500"
                            onClick={() => setActiveGame('pattern')}
                            score={highScores['pattern'] ? `Lvl ${highScores['pattern']}` : null}
                            delay={0.4}
                        />

                        {/* New Games */}
                        <GameCard
                            title="Tic-Tac-Toe"
                            desc="Classic 3x3. Beat the AI!"
                            icon={X}
                            color="from-blue-400 to-cyan-400"
                            onClick={() => setActiveGame('tictactoe')}
                            delay={0.45}
                        />
                        <GameCard
                            title="Rock Paper Scissors"
                            desc="Test your luck against the bot."
                            icon={Hand}
                            color="from-stone-400 to-stone-600"
                            onClick={() => setActiveGame('rps')}
                            delay={0.5}
                        />
                        <GameCard
                            title="Snake"
                            desc="Eat the food, don't hit the wall."
                            icon={Move}
                            color="from-green-500 to-emerald-600"
                            onClick={() => setActiveGame('snake')}
                            delay={0.55}
                        />
                    </motion.div>
                ) : (
                    <motion.div
                        initial={{ opacity: 0, scale: 0.95 }}
                        animate={{ opacity: 1, scale: 1 }}
                        exit={{ opacity: 0, scale: 0.95 }}
                        className="max-w-4xl mx-auto h-full flex flex-col w-full"
                    >
                        <button
                            onClick={() => setActiveGame(null)}
                            className="mb-2 text-white/50 hover:text-white flex items-center gap-2 transition-colors group px-4 py-2 rounded-full hover:bg-white/10 w-fit shrink-0"
                        >
                            <ArrowLeft size={20} className="group-hover:-translate-x-1 transition-transform" />
                            Back to Arcade
                        </button>

                        <div className="glass-card flex-1 flex flex-col relative overflow-hidden rounded-3xl border border-white/10 shadow-2xl bg-black/40 backdrop-blur-xl mb-4">
                            {activeGame === 'reaction' && <ReactionGame user={user} />}
                            {activeGame === 'number' && <NumberGuessGame user={user} />}
                            {activeGame === 'memory' && <MemoryGame user={user} />}
                            {activeGame === 'aim' && <AimTrainer user={user} />}
                            {activeGame === 'chimp' && <ChimpTest user={user} />}
                            {activeGame === 'pattern' && <PatternMatrix user={user} />}
                            {activeGame === 'tictactoe' && <TicTacToe user={user} />}
                            {activeGame === 'rps' && <RockPaperScissors user={user} />}
                            {activeGame === 'snake' && <SnakeGame user={user} />}
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    )
}

const GameCard = ({ title, desc, icon: Icon, color, onClick, delay, score }) => (
    <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay }}
        whileHover={{ scale: 1.03, y: -5 }}
        whileTap={{ scale: 0.97 }}
        onClick={onClick}
        className="glass-card p-1 cursor-pointer group hover:shadow-2xl hover:shadow-primary/20 transition-all duration-300 rounded-2xl relative"
    >
        {score && (
            <div className="absolute top-2 right-2 z-10 bg-black/60 px-2 py-0.5 rounded-full text-[10px] font-mono text-yellow-400 border border-yellow-500/30 flex items-center gap-1 shadow-lg backdrop-blur-md">
                <Trophy size={8} /> {score}
            </div>
        )}
        <div className="bg-[#1e293b]/80 p-5 h-full rounded-[14px] flex flex-col items-center text-center gap-3 border border-white/5 group-hover:border-white/20 transition-colors">
            <div className={`w-14 h-14 rounded-xl bg-gradient-to-tr ${color} flex items-center justify-center shadow-lg group-hover:shadow-[0_0_40px_rgba(255,255,255,0.2)] transition-all duration-500 group-hover:rotate-12`}>
                <Icon size={28} className="text-white drop-shadow-md" />
            </div>
            <div>
                <h3 className="text-lg font-bold mb-1 text-white group-hover:text-primary-light transition-colors">{title}</h3>
                <p className="text-gray-400 text-xs leading-relaxed line-clamp-2">{desc}</p>
            </div>
            <div className="mt-auto pt-2 w-full">
                <div className="w-full py-1.5 rounded-lg bg-white/5 group-hover:bg-white/10 text-primary-light font-bold text-[10px] tracking-widest uppercase transition-colors">
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
        }
    };

    const containerClick = () => {
        if (state === 'now') handleClick();
        else if (state === 'waiting' && timeoutRef.current) {
            clearTimeout(timeoutRef.current);
            alert("Too early! Wait for GREEN.");
            setState('waiting');
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

const AimTrainer = ({ user }) => {
    const [targets, setTargets] = useState([]);
    const [score, setScore] = useState(0);
    const [timeLeft, setTimeLeft] = useState(30);
    const [isPlaying, setIsPlaying] = useState(false);
    const [gameOver, setGameOver] = useState(false);

    // Spawn target
    const spawnTarget = () => {
        const id = Date.now() + Math.random();
        const x = Math.random() * 80 + 10;
        const y = Math.random() * 80 + 10;
        setTargets([{ id, x, y }]);
    };

    const startGame = () => {
        setScore(0);
        setTimeLeft(30);
        setIsPlaying(true);
        setGameOver(false);
        spawnTarget();
        if (user) axios.post(`${API_URL}/games/aim/start`, { user_id: user.id, difficulty: 'normal' }).catch(() => { });
    };

    const handleHit = (id) => {
        setScore(s => s + 1);
        spawnTarget(); // Instant respawn
    };

    useEffect(() => {
        if (!isPlaying) return;
        const interval = setInterval(() => {
            setTimeLeft(t => {
                if (t <= 1) {
                    setIsPlaying(false);
                    setGameOver(true);
                    if (user) axios.post(`${API_URL}/games/aim/submit`, { user_id: user.id, result: { score } }).catch(() => { });
                    return 0;
                }
                return t - 1;
            });
        }, 1000);
        return () => clearInterval(interval);
    }, [isPlaying, score, user]);

    return (
        <div className="flex-1 flex flex-col items-center justify-center relative bg-slate-900/50 cursor-crosshair overflow-hidden">
            {!isPlaying && !gameOver && (
                <div className="text-center z-10">
                    <Target size={80} className="mx-auto mb-6 text-red-500 drop-shadow-glow" />
                    <h2 className="text-4xl font-black mb-4">Aim Trainer</h2>
                    <p className="mb-8 text-gray-400">Click as many targets as you can in 30 seconds.</p>
                    <button onClick={startGame} className="btn-primary px-10 py-4 text-lg">Start</button>
                </div>
            )}

            {isPlaying && (
                <>
                    <div className="absolute top-4 left-0 right-0 flex justify-center gap-8 pointer-events-none select-none">
                        <div className="text-2xl font-bold font-mono text-white">Timer: <span className={timeLeft < 5 ? "text-red-500" : ""}>{timeLeft}s</span></div>
                        <div className="text-2xl font-bold font-mono text-primary-light">Score: {score}</div>
                    </div>
                    {targets.map(t => (
                        <motion.div
                            key={t.id}
                            initial={{ scale: 0 }} animate={{ scale: 1 }}
                            className="absolute w-12 h-12 md:w-16 md:h-16 rounded-full bg-red-500 border-4 border-white shadow-lg shadow-red-500/50 flex items-center justify-center cursor-pointer"
                            style={{ left: `${t.x}%`, top: `${t.y}%` }}
                            onMouseDown={(e) => { e.stopPropagation(); handleHit(t.id); }}
                        >
                            <div className="w-2 h-2 rounded-full bg-white" />
                        </motion.div>
                    ))}
                </>
            )}

            {gameOver && (
                <div className="text-center z-10 cursor-default">
                    <Target size={64} className="mx-auto mb-4 text-gray-500" />
                    <h2 className="text-3xl font-bold mb-2">Time's Up!</h2>
                    <div className="text-8xl font-black text-white mb-6 animate-bounce">{score} <span className="text-2xl text-gray-400">hits</span></div>
                    <p className="mb-8 text-gray-400">Avg Speed: {score > 0 ? (30000 / score).toFixed(0) : 0}ms per hit</p>
                    <button onClick={startGame} className="btn-primary px-8 py-3 flex items-center gap-2 mx-auto">
                        <RotateCcw size={20} /> Retry
                    </button>
                </div>
            )}
        </div>
    );
};

const ChimpTest = ({ user }) => {
    const [level, setLevel] = useState(4);
    const [numbers, setNumbers] = useState([]);
    const [nextNum, setNextNum] = useState(1);
    const [gameState, setGameState] = useState('menu');
    const [maxLevel, setMaxLevel] = useState(4);

    const generateLevel = (count) => {
        const nums = [];
        const positions = new Set();
        for (let i = 1; i <= count; i++) {
            let x, y, key;
            do {
                x = Math.floor(Math.random() * 8);
                y = Math.floor(Math.random() * 5);
                key = `${x},${y}`;
            } while (positions.has(key));
            positions.add(key);
            nums.push({ val: i, x, y, hidden: false });
        }
        setNumbers(nums);
        setNextNum(1);
        setGameState('memorize');
    };

    const startGame = () => {
        setLevel(4);
        setMaxLevel(4);
        generateLevel(4);
        if (user) axios.post(`${API_URL}/games/chimp/start`, { user_id: user.id }).catch(() => { });
    };

    const handleNumberClick = (num) => {
        if (gameState !== 'play' && gameState !== 'memorize') return;

        if (num.val === 1) {
            setGameState('play');
        }

        if (num.val === nextNum) {
            if (num.val === level) {
                if (level >= 20) {
                    setGameState('lost');
                } else {
                    setLevel(l => l + 1);
                    setMaxLevel(m => Math.max(m, level + 1));
                    generateLevel(level + 1);
                }
            } else {
                setNextNum(n => n + 1);
                setNumbers(prev => prev.filter(n => n.val !== num.val));
            }
        } else {
            setGameState('lost');
            if (user) axios.post(`${API_URL}/games/chimp/submit`, { user_id: user.id, result: { score: level - 1 } }).catch(() => { });
        }
    };

    return (
        <div className="flex-1 flex flex-col items-center justify-center p-4 relative">
            {gameState === 'menu' && (
                <div className="text-center z-10">
                    <Brain size={80} className="mx-auto mb-6 text-orange-500 drop-shadow-glow" />
                    <h2 className="text-4xl font-black mb-4">Chimp Test</h2>
                    <p className="mb-8 text-gray-400 max-w-sm mx-auto">Click the numbers in order (1, 2, 3...)<br />The catch? They disappear after you click 1.</p>
                    <button onClick={startGame} className="btn-primary px-10 py-4 text-lg">Start Test</button>
                </div>
            )}

            {(gameState === 'memorize' || gameState === 'play') && (
                <div className="relative w-full max-w-3xl h-[400px] flex items-center justify-center">
                    {numbers.map(n => (
                        <motion.div
                            key={n.val}
                            initial={{ scale: 0 }} animate={{ scale: 1 }}
                            className={`absolute w-14 h-14 md:w-16 md:h-16 rounded-xl border-4 text-3xl font-bold flex items-center justify-center cursor-pointer select-none transition-colors border-white/10 shadow-lg
                                ${gameState === 'play' && n.val > 1 ? 'bg-white text-transparent border-white' : 'bg-white/10 hover:bg-white/20 text-white'}
                            `}
                            style={{
                                left: `${(n.x / 8) * 100}%`,
                                top: `${(n.y / 5) * 100}%`,
                                marginLeft: '2%', marginTop: '2%'
                            }}
                            onMouseDown={() => handleNumberClick(n)}
                        >
                            {(gameState === 'memorize' || (gameState === 'play' && n.val === 1)) ? n.val : ''}
                        </motion.div>
                    ))}
                </div>
            )}

            {gameState === 'lost' && (
                <div className="text-center z-10">
                    <h2 className="text-3xl font-bold text-red-500 mb-2">Test Failed</h2>
                    <p className="text-gray-400 mb-2">You reached</p>
                    <div className="text-8xl font-black text-white mb-8">Level {level - 1}</div>
                    <button onClick={startGame} className="btn-primary px-8 py-3 flex items-center gap-2 mx-auto">
                        <RotateCcw size={20} /> Try Again
                    </button>
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
    const emojis = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼'];
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

const PatternMatrix = ({ user }) => {
    const [level, setLevel] = useState(1);
    const [gridSize, setGridSize] = useState(3);
    const [pattern, setPattern] = useState([]);
    const [userPattern, setUserPattern] = useState([]);
    const [status, setStatus] = useState('start'); // start, show, input, result
    const [lives, setLives] = useState(3);

    const generatePattern = (lvl, size) => {
        const tileCount = size * size;
        const numToSelect = Math.floor(lvl / 2) + 2;
        const newPattern = [];
        while (newPattern.length < numToSelect) {
            const r = Math.floor(Math.random() * tileCount);
            if (!newPattern.includes(r)) newPattern.push(r);
        }
        return newPattern;
    };

    const startGame = () => {
        setLevel(1);
        setLives(3);
        setGridSize(3);
        startLevel(1, 3);
        if (user) axios.post(`${API_URL}/games/pattern/start`, { user_id: user.id }).catch(() => { });
    };

    const startLevel = (lvl, size) => {
        setUserPattern([]);
        const newPattern = generatePattern(lvl, size);
        setPattern(newPattern);
        setStatus('show');

        // Show for 1s then hide
        setTimeout(() => {
            setStatus('input');
        }, 1000 + (lvl * 100));
    };

    const handleTileClick = (index) => {
        if (status !== 'input') return;

        // Check if already clicked
        if (userPattern.includes(index)) return;

        // Check if correct
        if (pattern.includes(index)) {
            const newUserPattern = [...userPattern, index];
            setUserPattern(newUserPattern);

            if (newUserPattern.length === pattern.length) {
                // Won level
                setStatus('result');
                setTimeout(() => {
                    const nextLvl = level + 1;
                    setLevel(nextLvl);
                    // Increase grid size every 3 levels
                    const nextSize = Math.floor(nextLvl / 3) + 3;
                    setGridSize(Math.min(nextSize, 6));
                    startLevel(nextLvl, Math.min(nextSize, 6));
                }, 500);
            }
        } else {
            // Wrong tile
            setLives(l => l - 1);
            if (lives <= 1) {
                setStatus('gameover');
                if (user) axios.post(`${API_URL}/games/pattern/submit`, { user_id: user.id, result: { score: level } }).catch(() => { });
            } else {
                // Show Pattern again
                setStatus('show');
                setUserPattern([]);
                setTimeout(() => setStatus('input'), 1000);
            }
        }
    };

    return (
        <div className="flex-1 flex flex-col items-center justify-center p-2 h-full">
            <div className="flex items-center justify-between w-full max-w-sm mb-4">
                <div className="text-xl font-bold">Level {level}</div>
                <div className="flex gap-1">
                    {[...Array(3)].map((_, i) => (
                        <div key={i} className={`w-3 h-3 rounded-full ${i < lives ? 'bg-red-500' : 'bg-gray-700'}`} />
                    ))}
                </div>
            </div>

            {status === 'start' && (
                <div className="text-center absolute inset-0 flex flex-col items-center justify-center bg-black/80 z-20">
                    <LayoutGrid size={64} className="mb-4 text-indigo-500" />
                    <h2 className="text-3xl font-bold mb-4">Visual Memory</h2>
                    <p className="mb-8 text-gray-400">Memorize the white tiles.</p>
                    <button onClick={startGame} className="btn-primary">Start</button>
                </div>
            )}

            {status === 'gameover' && (
                <div className="text-center absolute inset-0 flex flex-col items-center justify-center bg-black/90 z-20">
                    <h2 className="text-3xl font-bold text-red-500 mb-2">Game Over</h2>
                    <div className="text-6xl font-black text-white mb-6">Lvl {level}</div>
                    <button onClick={startGame} className="btn-primary flex items-center gap-2 mx-auto">
                        <RotateCcw size={20} /> Retry
                    </button>
                </div>
            )}

            <div
                className="grid gap-2 bg-slate-800 p-4 rounded-xl shadow-2xl aspect-square w-full max-w-xs md:max-w-sm"
                style={{
                    gridTemplateColumns: `repeat(${gridSize}, 1fr)`
                }}
            >
                {[...Array(gridSize * gridSize)].map((_, i) => {
                    const isActive = pattern.includes(i) && status === 'show';
                    const isSelected = userPattern.includes(i);
                    const isWrong = status === 'input' && isSelected && !pattern.includes(i);

                    return (
                        <motion.div
                            key={i}
                            whileHover={status === 'input' ? { scale: 0.95 } : {}}
                            whileTap={status === 'input' ? { scale: 0.9 } : {}}
                            onClick={() => handleTileClick(i)}
                            className={`rounded-lg cursor-pointer transition-colors duration-200
                                ${isActive || (isSelected && pattern.includes(i)) ? 'bg-white shadow-[0_0_15px_white]' : 'bg-slate-700/50 hover:bg-slate-700'}
                                ${isWrong ? 'bg-red-500' : ''}
                            `}
                        />
                    );
                })}
            </div>

            <div className="mt-8 h-8 text-gray-400 font-mono text-sm">
                {status === 'show' ? 'Memorize...' : status === 'input' ? 'Repeat the pattern' : ''}
            </div>
        </div>
    );
};
