// See LICENSE for license details.

#ifndef PLIC_H
#define PLIC_H

#ifdef __ASSEMBLER__
#define _AC(X,Y)        X
#define _AT(T,X)        X
#else
#define _AC(X,Y)        (X##Y)
#define _AT(T,X)        ((T)(X))
#endif /* !__ASSEMBLER__*/

#define _BITUL(x)       (_AC(1,UL) << (x))
#define _BITULL(x)      (_AC(1,ULL) << (x))

// 32 bits per source
#define PLIC_PRIORITY_OFFSET            _AC(0x0000,UL)
#define PLIC_PRIORITY_SHIFT_PER_SOURCE  2
// 1 bit per source (1 address)
#define PLIC_PENDING_OFFSET             _AC(0x1000,UL)
#define PLIC_PENDING_SHIFT_PER_SOURCE   0

//0x80 per target
#define PLIC_ENABLE_OFFSET              _AC(0x2000,UL)
#define PLIC_ENABLE_SHIFT_PER_TARGET    7

#define PLIC_THRESHOLD_OFFSET           _AC(0x200000,UL)
#define PLIC_CLAIM_OFFSET               _AC(0x200004,UL)
#define PLIC_THRESHOLD_SHIFT_PER_TARGET 12
#define PLIC_CLAIM_SHIFT_PER_TARGET     12

#define PLIC_MAX_SOURCE                 1023
#define PLIC_SOURCE_MASK                0x3FF

#define PLIC_MAX_TARGET                 15871
#define PLIC_TARGET_MASK                0x3FFF


typedef struct __plic_instance_t
{
  uintptr_t base_addr;

  uint32_t num_sources;
  uint32_t num_priorities;
  
} plic_instance_t;

typedef uint32_t plic_source;
typedef uint32_t plic_priority;
typedef uint32_t plic_threshold;

void PLIC_init (
                plic_instance_t * this_plic,
                uintptr_t         base_addr,
                uint32_t num_sources,
                uint32_t num_priorities
                );

void PLIC_set_threshold (plic_instance_t * this_plic,
			 plic_threshold threshold);
  
void PLIC_enable_interrupt (plic_instance_t * this_plic,
			    plic_source source);

void PLIC_disable_interrupt (plic_instance_t * this_plic,
			     plic_source source);
  
void PLIC_set_priority (plic_instance_t * this_plic,
			plic_source source,
			plic_priority priority);

plic_source PLIC_claim_interrupt(plic_instance_t * this_plic);

void PLIC_complete_interrupt(plic_instance_t * this_plic,
plic_source source);


#endif /* PLIC_H */
