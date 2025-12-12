import { useRef } from 'react';
import { motion, useScroll, useTransform } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { Sparkles, ArrowRight, Play, Cpu, Zap, Lock, Smile } from 'lucide-react';

export default function Landing() {
    const navigate = useNavigate();
    const targetRef = useRef(null);
    const { scrollYProgress } = useScroll();

    // Gentle Parallax for Hero Text
    const heroY = useTransform(scrollYProgress, [0, 0.4], [0, -50]);
    const heroOpacity = useTransform(scrollYProgress, [0, 0.3], [1, 0]);

    // Section Entry Animations
    const fadeInUp = {
        hidden: { opacity: 0, y: 40 },
        visible: { opacity: 1, y: 0, transition: { duration: 0.8, ease: [0.22, 1, 0.36, 1] } }
    };

    const staggerContainer = {
        visible: { transition: { staggerChildren: 0.2 } }
    };

    return (
        <div ref={targetRef} className="min-h-[300vh] relative overflow-hidden font-sans">

            {/* --- Mesh Gradient Background --- */}
            <div className="mesh-bg">
                <div className="mesh-blob blob-1" />
                <div className="mesh-blob blob-2" />
                <div className="mesh-blob blob-3" />
            </div>

            {/* --- Navigation --- */}
            <nav className="fixed top-0 w-full z-50 px-4 sm:px-6 py-5 glass-nav transition-all">
                <div className="max-w-7xl mx-auto flex items-center justify-between gap-4">
                    <div className="flex items-center gap-2 cursor-pointer" onClick={() => navigate('/')}>
                        <img src="/logo.png" alt="Logo" className="w-8 h-8 rounded-lg" />
                        <span className="font-bold text-lg tracking-tight text-slate-900">Boredom.ai</span>
                    </div>

                    <div className="flex items-center gap-3">
                        {/* Mobile Login Icon */}
                        <button onClick={() => navigate('/login')} className="sm:hidden p-2 text-gray-300 hover:text-white">
                            <span className="sr-only">Log in</span>
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4" /><polyline points="10 17 15 12 10 7" /><line x1="15" x2="3" y1="12" y2="12" /></svg>
                        </button>

                        {/* Desktop Login Text */}
                        <button onClick={() => navigate('/login')} className="hidden sm:block font-medium hover:text-primary transition-colors text-sm text-txt-muted">Log in</button>

                        <button onClick={() => navigate('/register')} className="bg-slate-900 text-white px-4 py-2 sm:px-5 sm:py-2.5 rounded-full font-bold text-xs sm:text-sm hover:scale-105 transition-transform shadow-lg shadow-slate-200 whitespace-nowrap">
                            Get Started
                        </button>
                    </div>
                </div>
            </nav>

            {/* --- Hero Section --- */}
            <motion.section
                style={{ y: heroY, opacity: heroOpacity }}
                className="relative z-10 min-h-screen flex flex-col items-center justify-center text-center px-6 pt-20"
            >
                <motion.div
                    initial="hidden"
                    animate="visible"
                    variants={staggerContainer}
                    className="max-w-5xl mx-auto"
                >
                    <motion.div variants={fadeInUp} className="mb-6 inline-flex items-center gap-2 px-6 py-2 rounded-full bg-white border border-primary/30 shadow-[0_0_15px_rgba(99,102,241,0.2)] backdrop-blur-sm">
                        <span className="text-sm font-bold uppercase tracking-widest text-primary">Reimagine Your Downtime</span>
                    </motion.div>

                    <motion.h1 variants={fadeInUp} className="text-6xl md:text-8xl font-black tracking-tight mb-8 leading-[1.1] text-txt-main">
                        Turn Boredom into <br />
                        <span className="gradient-text-anim">Brilliance.</span>
                    </motion.h1>

                    <motion.p variants={fadeInUp} className="text-xl md:text-2xl text-txt-muted max-w-2xl mx-auto mb-12 font-medium leading-relaxed">
                        Your AI companion that detects your mood and curates a personalized flow of activities, music, and micro-habits.
                    </motion.p>

                    <motion.div variants={fadeInUp} className="flex flex-col sm:flex-row items-center justify-center gap-4">
                        <button onClick={() => navigate('/register')} className="btn-primary flex items-center gap-2 text-lg shadow-xl px-10 py-5">
                            Start Your Journey <ArrowRight size={18} />
                        </button>
                    </motion.div>
                </motion.div>

                {/* Hero Logo Removed as requested */}
            </motion.section>

            {/* --- Bento Grid Features --- */}
            <section id="features" className="py-32 relative z-10">
                <div className="max-w-7xl mx-auto px-6">
                    <motion.div
                        initial={{ opacity: 0, y: 40 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.8 }}
                        viewport={{ once: true }}
                        className="mb-20"
                    >
                        <h2 className="text-4xl md:text-5xl font-bold mb-6">Designed for Flow State.</h2>
                    </motion.div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                        {/* Feature 1 */}
                        <motion.div
                            initial={{ opacity: 0, scale: 0.95 }}
                            whileInView={{ opacity: 1, scale: 1 }}
                            transition={{ duration: 0.6 }}
                            viewport={{ once: true }}
                            className="md:col-span-2 glass-card p-10 min-h-[400px] flex flex-col justify-between relative overflow-hidden group"
                        >
                            <div className="relative z-10 max-w-lg">
                                <div className="w-12 h-12 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center mb-6">
                                    <Cpu size={24} />
                                </div>
                                <h3 className="text-3xl font-bold mb-4 text-txt-main">Neural Engine</h3>
                                <p className="text-txt-muted text-lg">
                                    Our proprietary AI analyzes 50+ data points from your voice and text to accurately map your emotional state and prescribe the perfect antidote.
                                </p>
                            </div>
                            <div className="absolute right-[-40px] bottom-[-40px] w-80 h-80 bg-gradient-to-br from-blue-100 to-purple-100 rounded-full blur-[60px] opacity-0 group-hover:opacity-100 transition-opacity duration-700" />
                        </motion.div>

                        {/* Feature 2 */}
                        <motion.div
                            initial={{ opacity: 0, scale: 0.95 }}
                            whileInView={{ opacity: 1, scale: 1 }}
                            transition={{ duration: 0.6, delay: 0.1 }}
                            viewport={{ once: true }}
                            className="glass-card p-10 flex flex-col justify-between group"
                        >
                            <div>
                                <div className="w-12 h-12 rounded-2xl bg-rose-50 text-rose-600 flex items-center justify-center mb-6">
                                    <Zap size={24} />
                                </div>
                                <h3 className="text-2xl font-bold mb-2 text-txt-main">Micro-Tasks</h3>
                                <p className="text-txt-muted">Bite-sized actions generated instantly to break paralysis.</p>
                            </div>
                            <div className="h-32 w-full bg-gray-50 rounded-2xl mt-8 overflow-hidden relative">
                                <div className="absolute top-4 left-4 right-4 h-2 bg-gray-200 rounded-full" />
                                <div className="absolute top-8 left-4 w-2/3 h-2 bg-gray-200 rounded-full" />
                                <motion.div
                                    animate={{ x: [-100, 200] }}
                                    transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                                    className="absolute top-0 bottom-0 w-8 bg-white/50 skew-x-12 blur-md"
                                />
                            </div>
                        </motion.div>

                        {/* Feature 3 */}
                        <motion.div
                            initial={{ opacity: 0, scale: 0.95 }}
                            whileInView={{ opacity: 1, scale: 1 }}
                            transition={{ duration: 0.6, delay: 0.2 }}
                            viewport={{ once: true }}
                            className="glass-card p-10 flex flex-col justify-between group"
                        >
                            <div>
                                <div className="w-12 h-12 rounded-2xl bg-purple-50 text-purple-600 flex items-center justify-center mb-6">
                                    <Lock size={24} />
                                </div>
                                <h3 className="text-2xl font-bold mb-2 text-txt-main">Private Vault</h3>
                                <p className="text-txt-muted">AES-256 encrypted journaling space.</p>
                            </div>
                        </motion.div>

                        {/* Feature 4 */}
                        <motion.div
                            initial={{ opacity: 0, scale: 0.95 }}
                            whileInView={{ opacity: 1, scale: 1 }}
                            transition={{ duration: 0.6, delay: 0.3 }}
                            viewport={{ once: true }}
                            className="md:col-span-2 glass-card p-10 bg-[#111827] text-white relative overflow-hidden"
                        >
                            <div className="relative z-10 flex flex-col md:flex-row items-center gap-10">
                                <div className="flex-1">
                                    <div className="flex items-center gap-2 mb-4 text-emerald-400">
                                        <Smile size={20} />
                                        <span className="font-bold uppercase tracking-wider text-xs">Mood Tracking</span>
                                    </div>
                                    <h3 className="text-3xl font-bold mb-4">Visualize Your Progress</h3>
                                    <p className="text-gray-400">
                                        See your emotional trends over time with beautiful, interactive charts. Understand what triggers your best days.
                                    </p>
                                </div>
                                <div className="w-full md:w-1/2 aspect-video bg-white/5 rounded-2xl border border-white/10 p-6 flex items-end gap-2">
                                    {[40, 70, 50, 90, 60, 80].map((h, i) => (
                                        <motion.div
                                            key={i}
                                            initial={{ height: 0 }}
                                            whileInView={{ height: `${h}%` }}
                                            transition={{ duration: 1, delay: i * 0.1 }}
                                            className="flex-1 bg-gradient-to-t from-emerald-500/20 to-emerald-500 rounded-t-lg"
                                        />
                                    ))}
                                </div>
                            </div>
                        </motion.div>
                    </div>
                </div>
            </section>

            {/* --- Minimal CTA --- */}
            <section className="py-40 relative z-10 px-6 text-center">
                <motion.div
                    initial={{ opacity: 0, y: 40 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.8 }}
                    viewport={{ once: true }}
                    className="max-w-4xl mx-auto"
                >
                    <h2 className="text-5xl md:text-7xl font-bold mb-10 tracking-tight text-txt-main">
                        Ready to optimize your <br /> mental state?
                    </h2>
                    <button
                        onClick={() => navigate('/register')}
                        className="px-10 py-5 bg-primary text-white rounded-full font-bold text-xl hover:scale-105 transition-transform shadow-xl shadow-primary/30"
                    >
                        Create Free Account
                    </button>
                </motion.div>
            </section>

            {/* --- Simple Footer --- */}
            <footer className="py-12 border-t border-slate-200 bg-white/50 backdrop-blur-sm">
                <div className="max-w-7xl mx-auto px-6 flex flex-col md:flex-row justify-between items-center text-sm text-txt-muted">
                    <p>&copy; 2025 Boredom Breaker Inc. All rights reserved.</p>
                    <div className="flex gap-6 mt-4 md:mt-0">
                        <a href="#" className="hover:text-primary transition-colors">Twitter</a>
                        <a href="#" className="hover:text-primary transition-colors">GitHub</a>
                        <a href="#" className="hover:text-primary transition-colors">Privacy</a>
                    </div>
                </div>
            </footer>
        </div>
    );
}
