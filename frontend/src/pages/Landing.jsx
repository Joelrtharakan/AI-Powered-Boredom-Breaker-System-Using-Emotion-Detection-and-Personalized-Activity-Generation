import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { ArrowRight, Sparkles, Zap, Brain, Shield, Gamepad2, Mic, Activity, CheckCircle, ChevronRight, Play } from 'lucide-react';
import { useState } from 'react';

export default function Landing() {
    const navigate = useNavigate();

    return (
        <div className="min-h-screen relative overflow-hidden flex flex-col bg-dark text-white selection:bg-neon-pink selection:text-white">
            {/* --- Background Elements --- */}
            <div className="fixed inset-0 z-0 pointer-events-none">
                <div className="absolute top-[-10%] left-[-10%] w-[50vw] h-[50vw] bg-primary-dark/20 rounded-full blur-[120px] animate-blob" />
                <div className="absolute bottom-[-10%] right-[-10%] w-[50vw] h-[50vw] bg-neon-purple/10 rounded-full blur-[120px] animate-blob animation-delay-2000" />
                <div className="absolute top-[40%] left-[40%] w-[30vw] h-[30vw] bg-neon-blue/5 rounded-full blur-[100px] animate-blob animation-delay-4000" />
            </div>

            {/* --- Navbar --- */}
            <nav className="fixed top-0 w-full z-50 px-6 py-4 glass border-b border-white/5 bg-dark/50 backdrop-blur-md">
                <div className="max-w-7xl mx-auto flex items-center justify-between">
                    <div className="flex items-center gap-2">
                        <img src="/logo.png" alt="Logo" className="w-10 h-10 rounded-lg shadow-neon" />
                        <span className="font-bold text-xl tracking-tight hidden md:block">Boredom Breaker</span>
                    </div>
                    <div className="hidden md:flex items-center gap-8 text-sm font-medium text-gray-300">
                        <a href="#features" className="hover:text-white transition-colors">Features</a>
                        <a href="#how-it-works" className="hover:text-white transition-colors">How it Works</a>
                        <a href="#pricing" className="hover:text-white transition-colors">Pricing</a>
                    </div>
                    <div className="flex items-center gap-4">
                        <button onClick={() => navigate('/login')} className="text-gray-300 hover:text-white font-medium text-sm">Sign In</button>
                        <button onClick={() => navigate('/register')} className="bg-white text-dark px-5 py-2 rounded-full font-bold text-sm hover:scale-105 transition-transform shadow-lg shadow-white/10">
                            Get Started
                        </button>
                    </div>
                </div>
            </nav>

            {/* --- Hero Section --- */}
            <section className="relative z-10 pt-32 pb-20 md:pt-48 md:pb-32 px-4">
                <div className="max-w-7xl mx-auto text-center flex flex-col items-center">
                    <motion.div
                        initial={{ opacity: 0, y: 30 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.8 }}
                        className="mb-8 relative"
                    >
                        <div className="absolute -inset-1 rounded-full bg-gradient-to-r from-neon-blue to-neon-purple opacity-30 blur-lg animate-pulse" />
                        <span className="relative px-6 py-2 rounded-full glass border border-white/20 text-sm font-medium tracking-wider uppercase text-gray-300 flex items-center gap-2">
                            <Sparkles size={14} className="text-neon-pink" />
                            AI-Powered Mental Wellness v2.0
                        </span>
                    </motion.div>

                    <motion.h1
                        initial={{ opacity: 0, scale: 0.9 }}
                        animate={{ opacity: 1, scale: 1 }}
                        transition={{ duration: 0.8, delay: 0.2 }}
                        className="text-5xl md:text-8xl font-black mb-8 tracking-tight leading-[1.1]"
                    >
                        <span className="text-white">Break Free From</span>
                        <br />
                        <span className="bg-clip-text text-transparent bg-gradient-to-r from-neon-blue via-primary-light to-neon-pink">Infinite Boredom</span>
                    </motion.h1>

                    <motion.p
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        transition={{ duration: 0.8, delay: 0.4 }}
                        className="text-lg md:text-2xl text-gray-400 max-w-2xl mb-12 font-light leading-relaxed"
                    >
                        Your intelligent companion that detects your mood and generates personalized activities, games, and music to lift your spirits instantly.
                    </motion.p>

                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.8, delay: 0.6 }}
                        className="flex flex-col md:flex-row gap-4 md:gap-6 w-full md:w-auto"
                    >
                        <button onClick={() => navigate('/register')} className="btn-primary text-xl px-10 py-5 group shadow-neon-hover w-full md:w-auto">
                            Start Your Journey
                            <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
                        </button>
                        <button
                            onClick={() => document.getElementById('features').scrollIntoView({ behavior: 'smooth' })}
                            className="px-10 py-5 rounded-xl border border-white/10 glass hover:bg-white/10 text-xl font-bold transition-all w-full md:w-auto flex items-center justify-center gap-2"
                        >
                            <Play size={20} fill="currentColor" className="opacity-80" />
                            Watch Demo
                        </button>
                    </motion.div>

                    {/* Stats */}
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        transition={{ delay: 1 }}
                        className="mt-20 grid grid-cols-2 md:grid-cols-4 gap-8 md:gap-16 border-t border-white/5 pt-10"
                    >
                        <div>
                            <h3 className="text-3xl font-bold text-white mb-1">10k+</h3>
                            <p className="text-gray-500 text-sm uppercase tracking-wider">Active Users</p>
                        </div>
                        <div>
                            <h3 className="text-3xl font-bold text-white mb-1">500+</h3>
                            <p className="text-gray-500 text-sm uppercase tracking-wider">Activities</p>
                        </div>
                        <div>
                            <h3 className="text-3xl font-bold text-white mb-1">98%</h3>
                            <p className="text-gray-500 text-sm uppercase tracking-wider">Mood Boost</p>
                        </div>
                        <div>
                            <h3 className="text-3xl font-bold text-white mb-1">24/7</h3>
                            <p className="text-gray-500 text-sm uppercase tracking-wider">AI Support</p>
                        </div>
                    </motion.div>
                </div>
            </section>

            {/* --- Bento Grid Features Section --- */}
            <section id="features" className="py-24 relative z-10 bg-dark-card/50">
                <div className="max-w-7xl mx-auto px-6">
                    <div className="text-center mb-16">
                        <h2 className="text-sm font-bold text-neon-purple uppercase tracking-widest mb-2">Everything You Need</h2>
                        <h3 className="text-4xl md:text-5xl font-black text-white">The Ultimate Boredom Cure</h3>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-4 grid-rows-4 md:grid-rows-2 gap-6 h-[1200px] md:h-[600px]">
                        {/* Feature 1: Large Left */}
                        <motion.div
                            whileHover={{ scale: 1.02 }}
                            className="md:col-span-2 md:row-span-2 glass-card p-10 flex flex-col justify-between relative overflow-hidden group"
                        >
                            <div className="absolute inset-0 bg-gradient-to-br from-primary/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
                            <div className="relative z-10">
                                <div className="w-16 h-16 rounded-2xl bg-primary text-white flex items-center justify-center mb-6 shadow-neon">
                                    <Brain size={32} />
                                </div>
                                <h4 className="text-3xl font-bold mb-4">AI Mood Detection</h4>
                                <p className="text-gray-400 text-lg leading-relaxed max-w-sm">
                                    Our advanced NLP engine analyzes your text and voice to understand exactly how you feel, creating a hyper-personalized roadmap to happiness.
                                </p>
                            </div>
                            <div className="absolute -bottom-10 -right-10 w-64 h-64 bg-primary/30 blur-[80px] rounded-full" />
                            {/* Abstract UI Mockup */}
                            <div className="mt-8 bg-dark/80 border border-white/10 rounded-xl p-4 transform rotate-1 translate-y-4 group-hover:translate-y-2 transition-transform shadow-2xl">
                                <div className="flex items-center gap-3 mb-3">
                                    <div className="w-3 h-3 rounded-full bg-red-500" />
                                    <div className="w-3 h-3 rounded-full bg-yellow-500" />
                                    <div className="w-3 h-3 rounded-full bg-green-500" />
                                </div>
                                <div className="space-y-2">
                                    <div className="h-2 bg-gray-700 rounded-full w-3/4" />
                                    <div className="h-2 bg-gray-700 rounded-full w-1/2" />
                                </div>
                            </div>
                        </motion.div>

                        {/* Feature 2: Top Right */}
                        <motion.div whileHover={{ scale: 1.02 }} className="md:col-span-2 glass-card p-8 flex items-center justify-between relative overflow-hidden group">
                            <div className="absolute inset-0 bg-gradient-to-r from-neon-blue/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
                            <div className="relative z-10 max-w-[60%]">
                                <h4 className="text-2xl font-bold mb-2 flex items-center gap-2">
                                    <Zap className="text-neon-blue" /> Instant Micro-Tasks
                                </h4>
                                <p className="text-gray-400 text-sm">Beat procrastination with bite-sized, achievable 5-minute tasks generated instantly.</p>
                            </div>
                            <div className="relative z-10 w-24 h-24 bg-dark rounded-full border border-white/10 flex items-center justify-center ml-4">
                                <span className="text-3xl">🚀</span>
                            </div>
                        </motion.div>

                        {/* Feature 3: Bottom Mid */}
                        <motion.div whileHover={{ scale: 1.02 }} className="glass-card p-8 flex flex-col justify-center relative overflow-hidden group bg-gradient-to-b from-white/5 to-transparent">
                            <div className="w-12 h-12 rounded-xl bg-neon-pink/20 text-neon-pink flex items-center justify-center mb-4">
                                <Gamepad2 />
                            </div>
                            <h4 className="text-xl font-bold mb-2">Arcade Zone</h4>
                            <p className="text-gray-400 text-xs">Mini-games designed to boost dopamine.</p>
                        </motion.div>

                        {/* Feature 4: Bottom Right */}
                        <motion.div whileHover={{ scale: 1.02 }} className="glass-card p-8 flex flex-col justify-center relative overflow-hidden group bg-gradient-to-b from-white/5 to-transparent">
                            <div className="w-12 h-12 rounded-xl bg-green-500/20 text-green-400 flex items-center justify-center mb-4">
                                <Shield />
                            </div>
                            <h4 className="text-xl font-bold mb-2">Private Lockbox</h4>
                            <p className="text-gray-400 text-xs">AES-256 Encrypted journaling.</p>
                        </motion.div>
                    </div>
                </div>
            </section>

            {/* --- Interactive Demo Step Section --- */}
            <section id="how-it-works" className="py-32 px-6">
                <div className="max-w-7xl mx-auto">
                    <div className="flex flex-col md:flex-row items-center gap-16">
                        <div className="w-full md:w-1/2">
                            <h2 className="text-neon-blue font-bold tracking-widest uppercase mb-4">Seamless Flow</h2>
                            <h3 className="text-4xl md:text-5xl font-black mb-8 leading-tight">From Boredom to <br /><span className="text-white">Brilliance</span> in 3 Steps.</h3>

                            <div className="space-y-8">
                                {[
                                    { title: "Tell Us How You Feel", desc: "Type, speak, or select your current emotion." },
                                    { title: "Get Your Custom Plan", desc: "Receive a tailored list of activities, music, and micro-habits." },
                                    { title: "Engage & Track", desc: "Complete tasks, play games, and watch your mood stats improve." }
                                ].map((step, i) => (
                                    <div key={i} className="flex gap-6 group cursor-default">
                                        <div className="flex-shrink-0 w-12 h-12 rounded-full border border-white/20 flex items-center justify-center font-bold text-xl group-hover:bg-white group-hover:text-black transition-colors">
                                            {i + 1}
                                        </div>
                                        <div>
                                            <h4 className="text-xl font-bold mb-2 text-gray-200 group-hover:text-white transition-colors">{step.title}</h4>
                                            <p className="text-gray-500 group-hover:text-gray-400 transition-colors">{step.desc}</p>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </div>

                        {/* Interactive Graphic */}
                        <div className="w-full md:w-1/2 relative h-[500px] glass-card border border-white/10 flex items-center justify-center p-8">
                            <div className="absolute inset-0 bg-gradient-to-tr from-primary/10 to-neon-purple/5" />

                            {/* Mock Chat Interface */}
                            <div className="w-full max-w-xs bg-dark rounded-2xl border border-white/10 shadow-2xl overflow-hidden relative z-10">
                                <div className="bg-white/5 p-4 border-b border-white/10 flex items-center gap-3">
                                    <div className="w-3 h-3 rounded-full bg-red-500" />
                                    <div className="w-3 h-3 rounded-full bg-yellow-500" />
                                    <div className="w-3 h-3 rounded-full bg-green-500" />
                                </div>
                                <div className="p-6 space-y-4">
                                    <div className="bg-white/5 p-3 rounded-xl rounded-tl-none text-sm text-gray-300 w-3/4">
                                        I'm feeling super bored and unmotivated right now... 😫
                                    </div>
                                    <div className="bg-primary/20 border border-primary/30 p-3 rounded-xl rounded-tr-none text-sm text-white w-[85%] ml-auto">
                                        I hear you! Let's fix that. Here is a plan:
                                        <ul className="mt-2 space-y-1 list-disc list-inside opacity-80">
                                            <li>3-min Breathing Exercise</li>
                                            <li>Quick "Reaction Time" Game</li>
                                            <li>Listen to "Lofi Focus" Playlist</li>
                                        </ul>
                                    </div>
                                </div>
                                <div className="p-4 border-t border-white/10 bg-white/5">
                                    <div className="h-8 bg-white/10 rounded-lg w-full" />
                                </div>
                            </div>

                            {/* Floating Badges */}
                            <motion.div animate={{ y: [0, -10, 0] }} transition={{ duration: 4, repeat: Infinity }} className="absolute top-6 right-6 z-20 px-4 py-2 glass rounded-full text-xs font-bold text-neon-pink border border-neon-pink/30 shadow-lg bg-black/50">
                                Mood: Boredom (95%)
                            </motion.div>
                            <motion.div animate={{ y: [0, 10, 0] }} transition={{ duration: 5, repeat: Infinity }} className="absolute bottom-6 left-6 z-20 px-4 py-2 glass rounded-full text-xs font-bold text-green-400 border border-green-400/30 shadow-lg bg-black/50">
                                + Plan Generated
                            </motion.div>
                        </div>
                    </div>
                </div>
            </section>

            {/* --- Testimonials / Social Proof --- */}
            <section className="py-24 bg-gradient-to-b from-dark to-primary-dark/20 border-y border-white/5">
                <div className="max-w-7xl mx-auto px-6 text-center">
                    <h2 className="text-3xl font-bold mb-16">Loved by Productivity Seekers</h2>
                    <div className="grid md:grid-cols-3 gap-8">
                        {[
                            { name: "Sarah J.", role: "Designer", text: "This app literally saved my Sunday afternoons. The mini-games are addictive!" },
                            { name: "Mike T.", role: "Developer", text: "The journaling feature with AI prompts helps me get unblocked so fast." },
                            { name: "Jessica L.", role: "Student", text: "I love the Lofi music integration. Perfect for study sessions." }
                        ].map((t, i) => (
                            <div key={i} className="glass-card p-8 text-left relative">
                                <div className="text-4xl text-primary/30 font-serif absolute top-4 left-6">"</div>
                                <p className="text-gray-300 mb-6 relative z-10">{t.text}</p>
                                <div className="flex items-center gap-3">
                                    <div className="w-10 h-10 rounded-full bg-gradient-to-br from-gray-700 to-gray-900" />
                                    <div>
                                        <div className="font-bold text-white">{t.name}</div>
                                        <div className="text-xs text-primary-light">{t.role}</div>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* --- CTA Section --- */}
            <section className="py-32 px-6 relative overflow-hidden">
                <div className="max-w-5xl mx-auto glass-card p-12 md:p-24 text-center relative z-10 border border-primary/50">
                    <div className="absolute inset-0 bg-primary/10 blur-3xl -z-10" />
                    <h2 className="text-4xl md:text-6xl font-black mb-6">Ready to Break the Cycle?</h2>
                    <p className="text-xl text-gray-400 mb-10 max-w-2xl mx-auto">Join thousands of users who have transformed their downtime into prime time.</p>
                    <button onClick={() => navigate('/register')} className="btn-primary text-xl px-12 py-6 shadow-neon-hover">
                        Create Free Account
                    </button>
                </div>
            </section>

            {/* --- Footer --- */}
            <footer className="py-12 px-6 border-t border-white/5 bg-dark-card/30 text-sm md:text-base">
                <div className="max-w-7xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-8 mb-12">
                    <div>
                        <h4 className="font-bold text-white mb-4">Product</h4>
                        <ul className="space-y-2 text-gray-500">
                            <li><a href="#" className="hover:text-primary-light transition-colors">Features</a></li>
                            <li><a href="#" className="hover:text-primary-light transition-colors">Pricing</a></li>
                            <li><a href="#" className="hover:text-primary-light transition-colors">Download</a></li>
                        </ul>
                    </div>
                    <div>
                        <h4 className="font-bold text-white mb-4">Company</h4>
                        <ul className="space-y-2 text-gray-500">
                            <li><a href="#" className="hover:text-primary-light transition-colors">About Us</a></li>
                            <li><a href="#" className="hover:text-primary-light transition-colors">Careers</a></li>
                            <li><a href="#" className="hover:text-primary-light transition-colors">Contact</a></li>
                        </ul>
                    </div>
                    <div>
                        <h4 className="font-bold text-white mb-4">Resources</h4>
                        <ul className="space-y-2 text-gray-500">
                            <li><a href="#" className="hover:text-primary-light transition-colors">Blog</a></li>
                            <li><a href="#" className="hover:text-primary-light transition-colors">Community</a></li>
                            <li><a href="#" className="hover:text-primary-light transition-colors">Help Center</a></li>
                        </ul>
                    </div>
                    <div>
                        <h4 className="font-bold text-white mb-4">Legal</h4>
                        <ul className="space-y-2 text-gray-500">
                            <li><a href="#" className="hover:text-primary-light transition-colors">Privacy</a></li>
                            <li><a href="#" className="hover:text-primary-light transition-colors">Terms</a></li>
                        </ul>
                    </div>
                </div>
                <div className="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between text-gray-600 border-t border-white/5 pt-8">
                    <p>© 2025 AI Boredom Breaker. Built with ❤️ + 🤖</p>
                    <div className="flex gap-4 mt-4 md:mt-0">
                        <CheckCircle size={20} />
                        <Activity size={20} />
                    </div>
                </div>
            </footer>
        </div>
    );
}
